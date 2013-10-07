
#import "ImageBrowserView.h"
#import "ImageBrowserCell.h"


@implementation ImageBrowserView

//---------------------------------------------------------------------------------
// newCellForRepresentedItem:
//
// Allocate and return our own cell class for the specified item. The returned cell must not be autoreleased 
//---------------------------------------------------------------------------------
- (IKImageBrowserCell *) newCellForRepresentedItem:(id) cell
{
	return [[ImageBrowserCell alloc] init];
}

//---------------------------------------------------------------------------------
// drawRect:
//
// override draw rect and force the background layer to redraw if the view did resize or did scroll 
//---------------------------------------------------------------------------------
- (void) drawRect:(NSRect) rect
{
	//retrieve the visible area
	NSRect visibleRect = [self visibleRect];
	
	//compare with the visible rect at the previous frame
	if(!NSEqualRects(visibleRect, lastVisibleRect)){
		//we did scroll or resize, redraw the background
		[[self backgroundLayer] setNeedsDisplay];
		
		//update last visible rect
		lastVisibleRect = visibleRect;
	}
	
	[super drawRect:rect];
}

@end
