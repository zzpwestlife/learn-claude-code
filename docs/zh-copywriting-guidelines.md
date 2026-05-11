# 中文文案排版指北 (Chinese Copywriting Guidelines)

本项目文档遵循 [中文文案排版指北](https://github.com/mzlogin/chinese-copywriting-guidelines) 的规范. 为了降低沟通成本并增强文档可读性, 请在编写中文文档时严格遵守以下规则.

## 核心规则

### 1. 空格 (Spaces)

- **中英文之间需要增加空格**
  - ✅ 在 LeanCloud 上, 数据存储是围绕 `AVObject` 进行的.
  - ❌ 在LeanCloud上, 数据存储是围绕`AVObject`进行的.
  - ❌ 在 LeanCloud上, 数据存储是围绕`AVObject` 进行的.

- **中文与数字之间需要增加空格**
  - ✅ 今天出去买菜花了 5000 元.
  - ❌ 今天出去买菜花了 5000元.

- **数字与单位之间需要增加空格**
  - ✅ 我家的光纤入户宽带有 10 Gbps, SSD 一共有 20 TB.
  - ❌ 我家的光纤入户宽带有 10Gbps, SSD 一共有 10TB.
  - **例外**: 度 (°) 和百分比 (%) 与数字之间不需要增加空格.
    - ✅ 今天是 233° 的高温.
    - ✅ 新 MacBook Pro 有 15% 的 CPU 性能提升.

- **半角标点前不加空格**
  - ✅ 刚刚买了一部 iPhone, 好开心!
  - ❌ 刚刚买了一部 iPhone , 好开心 !

- **半角标点后空格按语种处理**
  - 后接中文时, 通常不额外加空格.
  - 后接英文或数字时, 增加 1 个空格.
  - ✅ 这个版本修复了登录问题, and improves startup time.
  - ✅ 发布后 2 天内, 共有 120 人完成升级.

- **链接之间增加空格 (推荐)**
  - ✅ 请 [提交一个 issue](https://github.com/) 并分配给相关同事.
  - ❌ 请[提交一个 issue](https://github.com/)并分配给相关同事.

### 2. 标点符号 (Punctuation)

- **优先使用半角标点 [important]**
  - ✅ 嗨! 你知道吗? 今天前台同事跟我说 "喵" 了!
  - ❌ 嗨！你知道吗？今天前台同事跟我说「喵」了！

- **不重复使用标点符号**
  - ✅ 德国队竟然战胜了巴西队!
  - ❌ 德国队竟然战胜了巴西队!!
  - ❌ 德国队竟然战胜了巴西队!!!!!!

- **数字使用半角字符**
  - ✅ 这件蛋糕只卖 1000 元.
  - ❌ 这件蛋糕只卖 １０００ 元.

- **完整英文整句保持英文标点**
  - ✅ 乔布斯那句话是怎么说的? "Stay hungry, stay foolish."
  - ❌ 乔布斯那句话是怎么说的? "Stay hungry，stay foolish。"

- **引号使用半角双引号, 需要嵌套时使用半角单引号**
  - ✅ "老师, '有条不紊' 的 '紊' 是什么意思?"
  - ❌ 「老师, 『有条不紊』的『紊』是什么意思?」

### 3. 名词 (Nouns)

- **专有名词使用正确的大小写**
  - ✅ GitHub, iPhone, Android, iOS, macOS
  - ❌ github, Iphone, android, ios, MacOs

- **不要使用不地道的缩写**
  - ✅ 我们需要一位熟悉 JavaScript, HTML5 的前端开发者.
  - ❌ 我们需要一位熟悉 Js, h5 的 FED.

## 自动化工具

为了协助遵守这些规则, 可以使用以下工具:
- VS Code 插件: `Pangu-Markdown` (自动在中英文之间添加空格)
- 命令行工具: `pangu` (npm install -g pangu)
