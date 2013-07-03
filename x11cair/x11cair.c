// gcc x11cair.c `pkg-config --cflags --libs x11 cairo` -o x11cair


#include<cairo.h>
#include<cairo-xlib.h>
#include<X11/Xlib.h>

#include<stdio.h>
#include<stdlib.h>

#define SIZEX 320
#define SIZEY 240

void paint(cairo_surface_t *cs)
{
    cairo_t *c;

    c=cairo_create(cs);
    
    cairo_rectangle(c, 0.0, 0.0, SIZEX, SIZEY);
    cairo_set_source_rgb(c, 0.0, 0.0, 0.5);
    cairo_fill(c);
    cairo_move_to(c, 40.0, 50.0);
    cairo_set_source_rgb(c, 1.0, 1.0, 0.0);
    cairo_show_text(c, "Hello World!");
    cairo_show_page(c);

    cairo_destroy(c);
}


int main()
{
    Display *dpy;
    Window rootwin;
    Window win;
    Colormap cmap;
    XEvent e;
    int scr;
    GC gc;

    if(!(dpy=XOpenDisplay(NULL))) {
        fprintf(stderr, "ERROR: could not open display\n");
        exit(1);
    }

    scr = DefaultScreen(dpy);
    rootwin = RootWindow(dpy, scr);
    cmap = DefaultColormap(dpy, scr);
    
    win=XCreateSimpleWindow(dpy, rootwin, 1, 1, SIZEX, SIZEY, 0, 
            BlackPixel(dpy, scr), BlackPixel(dpy, scr));
    
    XStoreName(dpy, win, "hello");
    
    gc=XCreateGC(dpy, win, 0, NULL);
    XSetForeground(dpy, gc, WhitePixel(dpy, scr));
    
    XSelectInput(dpy, win, ExposureMask|ButtonPressMask);
    
    XMapWindow(dpy, win);
    
    Atom wmDeleteMessage = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
    XSetWMProtocols(dpy, win, &wmDeleteMessage, 1);

    cairo_surface_t *cs;
    cs=cairo_xlib_surface_create(dpy, win, DefaultVisual(dpy, 0), SIZEX, SIZEY);
    
    while(1) {
        XNextEvent(dpy, &e);
        if(e.type==Expose && e.xexpose.count<1) {
            XDrawString(dpy, win, gc, 10, 10, "Hello World!", 12);
            paint(cs);
        }
        else if(e.type==ButtonPress) break;
        else if(e.type==ClientMessage && e.xclient.data.l[0] == wmDeleteMessage) {
            break;
        }
    }
    
    printf("destroying\n");
    
    cairo_surface_destroy(cs);
    //XDestroyWindow(dpy, win);
    XCloseDisplay(dpy);
    printf("closed display\n");
    
    return 0;
}
