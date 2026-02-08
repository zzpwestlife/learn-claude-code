module.exports = {
    pdf_options: {
        format: 'A4',
        margin: '20mm',
        printBackground: true,
    },
    css: `
        body { 
            font-family: "Noto Sans CJK SC", "PingFang SC", "Microsoft YaHei", sans-serif;
            font-size: 14px;
            line-height: 1.6;
        }
        pre { 
            page-break-inside: avoid; 
            background-color: #f6f8fa;
            padding: 16px;
            border-radius: 6px;
        }
        code {
            font-family: "Menlo", "Monaco", "Courier New", monospace;
        }
        h1, h2, h3 { 
            page-break-after: avoid; 
            color: #24292e;
        }
        h1 { border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; }
        h2 { border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; }
        blockquote {
            border-left: 4px solid #dfe2e5;
            color: #6a737d;
            padding-left: 1em;
            margin-left: 0;
        }
        img {
            max-width: 100%;
        }
        /* Highlight specific alerts */
        blockquote strong {
            color: #24292e;
        }
    `
};
