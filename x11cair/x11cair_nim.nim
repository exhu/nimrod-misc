import cairo, cairoxlib, x, xlib

const
    SIZEX = 320
    SIZEY = 240


proc paint(cs: PSurface) =
    var c: PContext = create(cs)

    c.rectangle(0.0, 0.0, SIZEX, SIZEY)
    c.set_source_rgb(0, 0, 0.5)
    c.fill
    c.move_to(40, 50)
    c.set_source_rgb(1, 1, 0)
    c.show_text("Hello World!")
    c.show_page

    c.destroy

proc main() =
    var
        dpy: PDisplay
        rootwin: TWindow
        win: TWindow
        cmap: TColormap
        e: TXEvent
        scr: cint
        gc: TGC

    dpy = XOpenDisplay(nil)
    if dpy == nil:
        echo "Failed to open display!"
        quit(1)

    scr = XDefaultScreen(dpy)
    rootwin = XRootWindow(dpy, scr)
    cmap = XDefaultColorMap(dpy, scr)
    
    win = XCreateSimpleWindow(dpy, rootwin, 1, 1, SIZEX, SIZEY, 0,
        XBlackPixel(dpy, scr), XBlackPixel(dpy, scr))

    discard XStoreName(dpy, win, "hello")

    gc = XCreateGC(dpy, win, 0, nil)
    discard XSetForeground(dpy, gc, XWhitePixel(dpy, scr))

    discard XSelectInput(dpy, win, ExposureMask or ButtonPressMask)

    discard XMapWindow(dpy, win)

    var wmDeleteMessage: TAtom = XInternAtom(dpy, "WM_DELETE_WINDOW", 
        xlib.TBool(false))
    discard XSetWMProtocols(dpy, win, addr(wmDeleteMessage), 1)

    var cs: PSurface = xlib_surface_create(dpy, win, XDefaultVisual(dpy, 0),
        SIZEX, SIZEY);

    while true:
        discard XNextEvent(dpy, addr(e))
        if e.theType == Expose and cast[PXExposeEvent](e.addr).count < 1:
            discard XDrawString(dpy, win , gc, 10, 10, "Hello World!", 12)
            paint(cs)

        elif e.theType == ButtonPress:
            break
        elif e.theType == ClientMessage and 
            cast[PAtom](e.xclient.data[0].addr)[] == wmDeleteMessage:
                    break

    echo "destroying"

    destroy(cs)

    discard XDestroyWindow(dpy, win)
    discard XCloseDisplay(dpy) 

    echo "closed display"

# ----
main()

