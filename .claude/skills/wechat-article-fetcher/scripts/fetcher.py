import os
import sys
import re
import requests
from bs4 import BeautifulSoup
from markdownify import markdownify as md
from urllib.parse import urlparse

def sanitize_filename(name):
    # 移除非法字符，并将空格替换为下划线
    name = re.sub(r'[\\/*?:"<>|]', "", name).strip()
    return name

def fetch_article(url, output_dir="."):
    print(f"Fetching {url}...")
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8"
    }
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except Exception as e:
        print(f"Error fetching URL: {e}")
        sys.exit(1)

    soup = BeautifulSoup(response.text, "html.parser")
    
    # 提取标题
    # 优先使用 og:title
    title_tag = soup.select_one("meta[property='og:title']")
    if title_tag:
        title = title_tag["content"]
    else:
        # 备选: twitter:title 或 title 标签
        title_tag = soup.select_one("meta[name='twitter:title']")
        if title_tag:
            title = title_tag["content"]
        else:
            title = soup.title.string if soup.title else "Untitled Article"
            
    safe_title = sanitize_filename(title)
    print(f"Title: {title}")
    
    # 创建目录
    article_dir = os.path.join(output_dir, safe_title)
    images_dir = os.path.join(article_dir, "images")
    os.makedirs(images_dir, exist_ok=True)
    
    # 提取正文
    # 微信公众号通常在 #js_content
    content_div = soup.select_one("#js_content")
    if not content_div:
        # 尝试其他可能的选择器，或者回退到 body
        content_div = soup.find("div", class_="rich_media_content")
    
    if not content_div:
        print("Error: Could not find article content (#js_content or .rich_media_content).")
        sys.exit(1)

    # 处理图片
    # 微信公众号图片使用 data-src
    imgs = content_div.find_all("img")
    print(f"Found {len(imgs)} images.")
    
    for i, img in enumerate(imgs):
        data_src = img.get("data-src") or img.get("src")
        if not data_src:
            continue
            
        # 忽略一些图标或非常小的图片（可选，这里先全部下载）
        
        # 下载图片
        try:
            # 确定扩展名
            # data-src 通常包含 wx_fmt=png 等
            ext = "jpg" # default
            parsed_url = urlparse(data_src)
            from urllib.parse import parse_qs
            qs = parse_qs(parsed_url.query)
            if 'wx_fmt' in qs:
                ext = qs['wx_fmt'][0]
            elif data_src.endswith('.png'): ext = 'png'
            elif data_src.endswith('.jpg') or data_src.endswith('.jpeg'): ext = 'jpg'
            elif data_src.endswith('.gif'): ext = 'gif'
            elif data_src.endswith('.webp'): ext = 'webp'
            
            # 修正 ext
            if ext == 'jpeg': ext = 'jpg'
            
            filename = f"img_{i+1:03d}.{ext}"
            filepath = os.path.join(images_dir, filename)
            
            # 只有当文件不存在时才下载（避免重复）
            if not os.path.exists(filepath):
                img_resp = requests.get(data_src, headers=headers, timeout=10)
                if img_resp.status_code == 200:
                    with open(filepath, "wb") as f:
                        f.write(img_resp.content)
            
            # 修改 src 为相对路径
            # 注意：在 HTML 中我们使用相对路径，确保在本地打开时能看到
            img["src"] = f"images/{filename}"
            # 移除 data-src
            if img.has_attr("data-src"):
                del img["data-src"]
            # 移除 style 中的 height/width 限制，或者保留
            # img['style'] = "max-width: 100%; height: auto;" 
                
        except Exception as e:
            print(f"Warning: Failed to download image {data_src}: {e}")

    # 保存 HTML
    html_path = os.path.join(article_dir, f"{safe_title}.html")
    # 简单的 HTML 包装
    html_content = f"""
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        body {{ max-width: 800px; margin: 0 auto; padding: 20px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; line-height: 1.6; }}
        img {{ max-width: 100%; height: auto; display: block; margin: 20px auto; }}
        p {{ margin-bottom: 1.5em; }}
    </style>
</head>
<body>
    <h1>{title}</h1>
    {content_div.prettify()}
</body>
</html>
    """
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    
    # 保存 Markdown
    md_path = os.path.join(article_dir, f"{safe_title}.md")
    # 使用 markdownify 转换
    # 我们的 content_div 里的 img src 已经被修改为 images/xxx.jpg
    md_content = md(str(content_div), heading_style="ATX")
    
    # 清理一些多余的空行
    md_content = re.sub(r'\n{3,}', '\n\n', md_content)
    
    final_md = f"# {title}\n\n{md_content}"
    
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(final_md)
        
    print(f"Done. Article saved to: {article_dir}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python fetcher.py <url> [output_dir]")
        sys.exit(1)
        
    url = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "."
    
    fetch_article(url, output_dir)
