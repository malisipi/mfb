# A framebuffer graphic library

> The library is unstable atm!

* 2D Graphic support (compatible with gg)
* Keyboard support (a little buggy)
* Mouse support

## Why MFB is exist while we have V's GG library?

| GG  | MFB |
|-----|-----|
| GG is a graphic library for designed desktop applications. It can be used any way as a desktop application. | MFB is designed a framebuffer graphic library for Linux. |
| Designed for desktop applications | Designed for Linux TTY |
| Require a (X11) display server    | Don't require a display server |
| GG is not written in Pure V. (GG is a wrapper for sokol graphic library) | MFB is written in Pure V |
| Supports unicode input/mouse | Supports only english layout (for now)/mouse |
| GG is not support framebuffer<sup>1</sup> | MFB's first goal is supporting frambuffer |
| GG has more powerful API | MFB has less powerful API |

<sup>1</sup>: It doesn't seems like GG will supported in future. [floooh/sokol #702](https://github.com/floooh/sokol/issues/702)

> After all, You can understand MFB is not enemy of GG. MFB's goal is making applications that made with GG have more platform and user.

## Support

|                          |                          |
|--------------------------|--------------------------|
|![](./docs/mui_demo.png)  |![](./docs/2048.png)      |
| ? |![](./docs/tetris.png)    |

* MUI (UI Kit) is supported by [`mfb-backend` branch](https://github.com/malisipi/mui/tree/mfb-backend)
* MUIMPV (The video player widget for MUI) is supported by [`mfb-backend` branch](https://github.com/malisipi/muimpv/tree/mfb-backend). (Requires MUI)
* Most basic gg application can be ported with changing `import gg` with `import malisipi.mfb as gg`. (Also `mfb.context` must be mutable as different than gg to draw.)

## Flags

|Flag|Description|
|-|-|
|`-d show_fps`| Shows fps count |
|`-d unlimited_fps`| Removes fps limit (It can be cause HIGH CPU usage) |

## License

* This project was licensed by Apache 2.0 License (`./LICENSE`)
* VPNG module was licensed by MIT License (`./vpng`) (The module was edited for making maximum compatibility with the library. The original module is [here](https://github.com/Henrixounez/vpng))
* `./examples/ported/mit` was licensed by MIT License (`./examples/ported/mit`)
* [Phinger Cursors](https://github.com/phisch/phinger-cursors/) is licensed by CC-BY-SA-4.0 (Author: phisch (Philipp Schaffrath) on GitHub) (`./assets/cursor`)
* [Google Icons](https://fonts.google.com/icons) is licensed by Apache 2.0 (`./examples/mfb-player/assets`).