# 卡片解码者网页版

这是从“卡片解码者”离线项目独立复制出的静态托管版本，不会修改原项目。网页的求解、测试、小游戏和规模测试均在用户浏览器中运行，不需要后端服务。

## 第一步：发布无卡图版

仓库中的 `docs` 就是完整部署目录，默认不显示卡图，也不包含壁纸。GitHub Pages 可直接从 `main` 分支的 `docs` 目录发布，不需要 Actions 工作流。

首次部署前，在 GitHub 仓库中打开：

1. `Settings` → `Pages`
2. 将 `Source` 设为 `Deploy from a branch`
3. Branch 选择 `main`，目录选择 `/docs`
4. 点击 `Save`

本版本约 3MB，所有核心功能都可离线计算；活动记录只保存在访问者自己的浏览器中。

## 第二步：接入中文卡图 R2

线上版仅支持中文高清卡图，不包含英文卡图。图片不会随网页整体下载，而是在某张卡实际出现在界面中时按需请求。

完成 [`R2-中文卡图部署.md`](R2-中文卡图部署.md) 后，把 `docs/site-config.js` 中的地址改成 R2 公共域名：

```js
window.CARD_DECODER_SITE_CONFIG = Object.freeze({
  chineseCardImageBaseUrl: 'https://cards.example.com',
});
```

未配置地址时，“中文高清（按需）”选项会自动禁用，求解功能不受影响。

## 目录

```text
docs/                               GitHub Pages 实际发布的网站文件
R2-中文卡图部署.md                  中文卡图对象存储说明
```
