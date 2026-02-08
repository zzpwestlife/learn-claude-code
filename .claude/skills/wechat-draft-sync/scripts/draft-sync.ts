import fs from 'fs';
import path from 'path';
import axios from 'axios';
import FormData from 'form-data';
import { marked } from 'marked';
import dotenv from 'dotenv';

dotenv.config();

const APP_ID = process.env.WECHAT_APP_ID;
const APP_SECRET = process.env.WECHAT_APP_SECRET;

if (!APP_ID || !APP_SECRET) {
  console.error('Error: WECHAT_APP_ID and WECHAT_APP_SECRET must be set in .env file or environment variables.');
  process.exit(1);
}

interface ArticleMetadata {
  title: string;
  author?: string;
  digest?: string;
  cover_image?: string;
  content_source_url?: string;
}

async function getAccessToken(): Promise<string> {
  const url = `https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=${APP_ID}&secret=${APP_SECRET}`;
  try {
    const response = await axios.get(url);
    if (response.data.errcode && response.data.errcode !== 0) {
      throw new Error(`Failed to get access token: ${response.data.errmsg}`);
    }
    return response.data.access_token;
  } catch (error: any) {
    throw new Error(`Error getting access token: ${error.message}`);
  }
}

async function uploadImageForContent(accessToken: string, imagePath: string): Promise<string> {
  const url = `https://api.weixin.qq.com/cgi-bin/media/uploadimg?access_token=${accessToken}`;
  const form = new FormData();
  
  if (!fs.existsSync(imagePath)) {
    throw new Error(`Image file not found: ${imagePath}`);
  }

  form.append('media', fs.createReadStream(imagePath));

  try {
    const response = await axios.post(url, form, {
      headers: {
        ...form.getHeaders()
      }
    });
    if (response.data.errcode && response.data.errcode !== 0) {
      throw new Error(`Failed to upload content image: ${response.data.errmsg}`);
    }
    return response.data.url;
  } catch (error: any) {
    throw new Error(`Error uploading content image: ${error.message}`);
  }
}

async function uploadCoverImage(accessToken: string, imagePath: string): Promise<string> {
  const url = `https://api.weixin.qq.com/cgi-bin/material/add_material?access_token=${accessToken}&type=image`;
  const form = new FormData();

  if (!fs.existsSync(imagePath)) {
    throw new Error(`Cover image file not found: ${imagePath}`);
  }

  form.append('media', fs.createReadStream(imagePath));

  try {
    const response = await axios.post(url, form, {
      headers: {
        ...form.getHeaders()
      }
    });
    if (response.data.errcode && response.data.errcode !== 0) {
      throw new Error(`Failed to upload cover image: ${response.data.errmsg}`);
    }
    return response.data.media_id;
  } catch (error: any) {
    throw new Error(`Error uploading cover image: ${error.message}`);
  }
}

function parseFrontmatter(content: string): { metadata: ArticleMetadata; body: string } {
  const frontmatterRegex = /^---\n([\s\S]*?)\n---\n/;
  const match = content.match(frontmatterRegex);

  if (match) {
    const frontmatterBlock = match[1];
    const body = content.replace(frontmatterRegex, '');
    const metadata: any = {};
    
    frontmatterBlock.split('\n').forEach(line => {
      const [key, ...valueParts] = line.split(':');
      if (key && valueParts.length > 0) {
        metadata[key.trim()] = valueParts.join(':').trim().replace(/^"|"$/g, '');
      }
    });

    return {
      metadata: metadata as ArticleMetadata,
      body
    };
  }

  return {
    metadata: { title: 'Untitled' },
    body: content
  };
}

async function processMarkdown(content: string, baseDir: string, accessToken: string): Promise<string> {
  const imageRegex = /!\[.*?\]\((.*?)\)/g;
  let match;
  let newContent = content;
  const matches = [];

  while ((match = imageRegex.exec(content)) !== null) {
    matches.push({ full: match[0], url: match[1] });
  }

  // Process images sequentially to avoid overwhelming
  for (const m of matches) {
    const imagePath = path.resolve(baseDir, m.url);
    console.log(`Processing image: ${imagePath}`);
    try {
      const wechatUrl = await uploadImageForContent(accessToken, imagePath);
      newContent = newContent.replace(m.url, wechatUrl);
      console.log(`Uploaded to: ${wechatUrl}`);
    } catch (e: any) {
      console.error(`Failed to upload image ${m.url}: ${e.message}`);
    }
  }

  return newContent;
}

async function addDraft(accessToken: string, article: any) {
  const url = `https://api.weixin.qq.com/cgi-bin/draft/add?access_token=${accessToken}`;
  try {
    const response = await axios.post(url, {
      articles: [article]
    });
    if (response.data.errcode && response.data.errcode !== 0) {
      throw new Error(`Failed to add draft: ${response.data.errmsg}`);
    }
    return response.data.media_id;
  } catch (error: any) {
    throw new Error(`Error adding draft: ${error.message}`);
  }
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length < 1) {
    console.error('Usage: bun run draft-sync.ts <path-to-markdown-file>');
    process.exit(1);
  }

  const filePath = path.resolve(args[0]);
  if (!fs.existsSync(filePath)) {
    console.error(`File not found: ${filePath}`);
    process.exit(1);
  }

  console.log('Reading file...');
  const fileContent = fs.readFileSync(filePath, 'utf-8');
  const { metadata, body } = parseFrontmatter(fileContent);

  if (!metadata.title) {
    metadata.title = path.basename(filePath, path.extname(filePath));
  }

  console.log(`Title: ${metadata.title}`);
  
  try {
    console.log('Getting access token...');
    const accessToken = await getAccessToken();

    let thumb_media_id = '';
    if (metadata.cover_image) {
      const coverPath = path.resolve(path.dirname(filePath), metadata.cover_image);
      console.log(`Uploading cover image: ${coverPath}`);
      thumb_media_id = await uploadCoverImage(accessToken, coverPath);
    } else {
      console.warn('Warning: No cover image (cover_image) specified in frontmatter.');
      // You might want to upload a default image or fail here
    }

    console.log('Processing content images...');
    const processedMarkdown = await processMarkdown(body, path.dirname(filePath), accessToken);

    console.log('Converting to HTML...');
    const htmlContent = await marked.parse(processedMarkdown);

    const article = {
      title: metadata.title,
      author: metadata.author,
      digest: metadata.digest,
      content: htmlContent,
      content_source_url: metadata.content_source_url,
      thumb_media_id: thumb_media_id,
      need_open_comment: 0,
      only_fans_can_comment: 0
    };

    console.log('Uploading draft...');
    const mediaId = await addDraft(accessToken, article);
    console.log(`Success! Draft created with media_id: ${mediaId}`);

  } catch (error: any) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

main();
