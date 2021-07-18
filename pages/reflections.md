# Reflections

- We need to give a name to the application for system representing an ASCII art
  drawing canvas.
  
  Good candidates are: `Canvas`, `AsciiCanvas`. But I want to differentiate a `Canvas`
  library and a `Canvas` struct representing a canvas. So let's disturb that name
  a little to get a `Canva`. It reminds a purpose, short to call, 
  there are present products with such name, but we don't mind that.

- I want to maintain a separation between web-interface and canvas logic. 
  Even I can do it just like with anything by putting them in different
  contextes, I will go with umbrella application. It will give me strictier 
  boundaries and the ability to distribute canvas library separately if we will
  need that in the future.
