# FFmpeg AAC 编码器（WebAssembly）的对应源码与构建说明

哇奥（waao）的剪辑节点在用户的浏览器里导出成片。浏览器自带 AAC 编码时直接用浏览器的；没有时（例如 Firefox、Linux 上的
Chrome）会加载 [`@mediabunny/aac-encoder`](https://www.npmjs.com/package/@mediabunny/aac-encoder) **1.65.2**，它内含
[FFmpeg](https://ffmpeg.org/) 的 AAC 编码器，编译成了 WebAssembly。FFmpeg 以 LGPL 2.1 或更高版本授权，这个仓库按许可提供
对应的源代码与构建说明。

## 来源

`@mediabunny/aac-encoder` 1.65.2 里的 `build/aac.js`（WebAssembly 内联在其中）由下面这些构建：

| 组成                  | 版本                                                                                                                                   |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| FFmpeg                | 提交 [`60a2818f76dcd1fee3155b1791304af104a0fc1b`](https://github.com/FFmpeg/FFmpeg/commit/60a2818f76dcd1fee3155b1791304af104a0fc1b)（`n9.1-dev-2902-g60a2818f76d`），未修改 |
| Emscripten            | 4.0.21（`d6f42310010ddec0753a69bab01a4b33aae255b7`）                                                                                   |
| JavaScript 与 FFmpeg 的桥接 | [`src/bridge.c`](src/bridge.c)，取自 `@mediabunny/aac-encoder` 1.65.2                                                         |

- 上游给出的 WebAssembly 的 SHA-256：`4123d56ed650255a14535d8438680a78df67ae9324e4874a88becfb37bf18c66`。
- 只启用了 `avcodec` 与 AAC 编码器，没有启用 GPL、LGPL v3 与 nonfree 组件。

## 源代码

- FFmpeg 在上述提交的完整源码：本仓库 [Releases](../../releases) 里的
  `ffmpeg-60a2818f76dcd1fee3155b1791304af104a0fc1b.tar.gz`
  （SHA-256 `50cac4cd224ec15e613b2180e654466a2ee25f86dde77c88228b80cda69f7351`），也可以从 FFmpeg 官方仓库取同一提交。
- 桥接代码：[`src/bridge.c`](src/bridge.c)。

## 构建

装好 [Emscripten](https://emscripten.org/docs/getting_started/downloads.html) 4.0.21 并 `source emsdk_env.sh`，解开上面的源码包，然后：

```bash
./build.sh /path/to/FFmpeg-60a2818f76dcd1fee3155b1791304af104a0fc1b
```

生成的 `build/aac.js` 同时含 JavaScript 胶水代码与内联的 WebAssembly。[`build.sh`](build.sh) 里的参数与上游
`@mediabunny/aac-encoder` 1.65.2 的 README「Building and development」一节一致。

要使用修改过的 FFmpeg：改好源码后按同样的步骤重编，再按 [Mediabunny](https://github.com/Vanilagy/mediabunny) 的说明在
其仓库根目录 `npm run build` 生成新的 `@mediabunny/aac-encoder`。

## 许可

- FFmpeg：LGPL 2.1 或更高版本，见 [`licenses/ffmpeg`](licenses/ffmpeg)。
- `src/bridge.c` 与 `@mediabunny/aac-encoder`：Mozilla Public License 2.0，见 [`licenses/mediabunny`](licenses/mediabunny)。

---

# Corresponding source for the FFmpeg AAC encoder (WebAssembly)

waao's editing node exports videos in the user's browser. When the browser has no native AAC encoder (e.g. Firefox, Chrome on
Linux), it loads `@mediabunny/aac-encoder` **1.65.2**, which bundles FFmpeg's AAC encoder compiled to WebAssembly. FFmpeg is
licensed under the LGPL v2.1 or later; this repository provides the corresponding source and build instructions.

- Built from FFmpeg commit `60a2818f76dcd1fee3155b1791304af104a0fc1b` (unmodified), Emscripten 4.0.21 and `src/bridge.c`.
- FFmpeg source archive: see this repository's Releases (SHA-256 above), or the same commit in the official FFmpeg repository.
- Build: `./build.sh /path/to/ffmpeg-source` with Emscripten 4.0.21.
- Licenses: FFmpeg under LGPL v2.1 or later (`licenses/ffmpeg`); `bridge.c` and `@mediabunny/aac-encoder` under MPL-2.0
  (`licenses/mediabunny`).
