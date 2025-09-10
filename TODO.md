# Image Flow

A node-based image effects composer.

### TODO
- [iOS] Dragging edges with the finger is cumbersome because the finger
  obscures the end of the edge that is being dragged.
- [AnnotationView] Change the positioning so that it is placed above the point
  instead of below. On the ipad the message often gets obsured by the finger.
- [BUG]:[NodeControls]:[macOS] Dark mode backround color for number input 
- Remove focus from any node controls (e.g., number input) when the user touches/clicks anything
- Asset Browser
- Node Controls
  - Image
  - Integer
  - Vectors
  - Colors
  - Transforms

### NEXT
- Node Inspector
- Backend integration service
- Previews

### DOING
- Node selection system
  - [ ] Move selected nodes together
  - [ ] Menu commands
    - Select All
    - Deselect

### DONE
- [iOS] NodeNumberInput: drag to change values
- [CanvasFeature] Update node data store when a node input control changes value
- [iOS] Use `Dispatcher` action to create node via the palette 
- [macOS] Sidebar feature
  - [X] Drag-and-drop to create node in canvas
  - [X] Double-click to create node in canvas
- Canvas Annotations (E.g., error messages, etc.)
  - [X] `AnnotationView`
- Basic NodePalette
- [iOS] Node palette new node position
- Node Edges
  - [X] Draw full edges
  - [X] Port drag events
  - [X] Drag port to create edge / Draw partial edges
