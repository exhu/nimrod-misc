/* 
 * File:   main.c
 * Author: yur
 *
 * Created on November 18, 2012, 6:16 PM
 */

#include <stdio.h>
#include <stdlib.h>

#include <xcb/xcb.h>


#if 0
int main(int argc, char** argv) {

    xcb_connection_t *c = xcb_connect (NULL, NULL);
    
    
    xcb_disconnect (c);    
    
    return (EXIT_SUCCESS);
}

#endif

#include <cairo-xcb.h>

uint16_t xcb_win_height = 200;
uint16_t xcb_win_width = 200;


xcb_visualtype_t *get_root_visual_type(xcb_screen_t *s)
{
    xcb_visualtype_t *visual_type = NULL;
    xcb_depth_iterator_t depth_iter;

    depth_iter = xcb_screen_allowed_depths_iterator(s);

    for(;depth_iter.rem;xcb_depth_next(&depth_iter)) {
        xcb_visualtype_iterator_t visual_iter;

        visual_iter = xcb_depth_visuals_iterator(depth_iter.data);
        for(;visual_iter.rem;xcb_visualtype_next(&visual_iter)) {
            if(s->root_visual == visual_iter.data->visual_id) {
                visual_type = visual_iter.data;
                break;
            }
        }
    }

    return visual_type;
}


int
main ()
{
    xcb_connection_t    *c;
    xcb_screen_t        *screen;
    xcb_visualtype_t    *vistype;
    xcb_drawable_t       win;
    xcb_gcontext_t       foreground;
    xcb_generic_event_t *e;
    uint32_t             mask = 0;
    uint32_t             values[2];

    /* Open the connection to the X server */
    c = xcb_connect (NULL, NULL);

    /* Get the first screen */
    screen = xcb_setup_roots_iterator (xcb_get_setup (c)).data;
    vistype = get_root_visual_type (screen);

    /* Create black (foreground) graphic context */
    win = screen->root;

    foreground = xcb_generate_id (c);
    mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
    values[0] = screen->black_pixel;
    values[1] = 0;
    xcb_create_gc (c, foreground, win, mask, values);

    /* Ask for our window's Id */
    win = xcb_generate_id(c);

    /* Create the window */
    mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    values[0] = screen->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE;
    xcb_create_window (c,                             /* Connection          */
                       XCB_COPY_FROM_PARENT,          /* depth               */
                       win,                           /* window Id           */
                       screen->root,                  /* parent window       */
                       0, 0,                          /* x, y                */
                       150, 150,                      /* width, height       */
                       10,                            /* border_width        */
                       XCB_WINDOW_CLASS_INPUT_OUTPUT, /* class               */
                       screen->root_visual,           /* visual              */
                       mask, values);                 /* masks */

    /* Map the window on the screen */
    xcb_map_window (c, win);


    /* We flush the request */
    xcb_flush (c);

    while ((e = xcb_wait_for_event (c))) {
        switch (e->response_type & ~0x80) {
        case XCB_CONFIGURE_NOTIFY: {
            xcb_configure_notify_event_t *ec = (xcb_configure_notify_event_t *) e;

            xcb_win_width = ec->width;
            xcb_win_height = ec->height;
            } break;
        case XCB_EXPOSE: {
               
            cairo_surface_t *surface;
            cairo_t *cr;

            // xcb_clear_area (xcb_conn, 0, xcb_win, 0, 0, 0, 0);

            surface = cairo_xcb_surface_create (c, win, vistype,
                                                xcb_win_width, xcb_win_height);
            cr = cairo_create (surface);

            cairo_set_source_rgba (cr, 0, 0, 0, 1);
            cairo_move_to (cr, 10, 40);
            cairo_set_font_size (cr, 20);
            cairo_show_text (cr, "Hello World.");
           
            if (cairo_status (cr)) {
                printf ("Cairo is unhappy: %s\n",
                        cairo_status_to_string (cairo_status(cr)));
                exit(0);
            }
           
            cairo_destroy(cr);

            /* We flush the request */
            xcb_flush (c);

            break;
        }
        default: {
            /* Unknown event type, ignore it */
            break;
        }
        }
        /* Free the Generic Event */
        free (e);
    }

    return 0;
}


