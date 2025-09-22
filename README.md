# vmicroui

![docs/screenshot.png](docs/screenshot.png)

V-lang port of [microui](https://github.com/rxi/microui)

> [!WARNING]
> Currently `icon` is not implemented.

## Usage

[demo.v](https://github.com/funatsufumiya/vmicroui/blob/main/demo/demo.v)

```bash
$ git clone https://github.com/funatsufumiya/vmicroui ~/.vmodules/microui
$ v run ~/.vmodules/microui/demo/demo.v
```

### debug

```bash
$ v -g -cc clang -keepc demo/demo.v
# and debug demo/demo(.exe)
```

## TODOs

- I'd like to port whole of [sgl microui](https://floooh.github.io/sokol-html5/sgl-microui-sapp.html) into V.

----

Original README: [README_ORIG.md](README_ORIG.md)
