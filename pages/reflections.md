# Reflections

Steps are written in the moment and in chronological order.

## Steps

### Creating new project

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

### Before start

Before actually implementing something I want to prepare the repository to work.

I want to add local hooks to prevent accidentally commit code that is:

- Unformatted
- emitting warnings
- having dialyxir issues
- having credo issues
- failing tests

After that do the same checks on the repository side.

### First test

It's great that we already have acceptance tests in the assignment, we just
need to think about how to name structs and functions around them.

Essential pieces that can give insight to us are:

```
### Canvas should be…

- identifiable with a globally unique identifier.
- persisted across application launches.
```

```
- Drawing operations are applied to the canvas in the same order that they are passed in to the server.
```

We should try to follow naming conventions from the assignment, it helps to
establish the same language between people who describe a problem domain and
developers who build an implementation of these ideas.

If it is possible I would propose to the team to name the Canvas, a CanvasDocument,
or just a Document, to avoid names clash with canvas related to rendering
wish is not caring about its `id` or storing capabilities. But in many areas
of knowledge, the names are well established and we just have to follow them.

Let's try following:

- Canvas{id, size}
- Operation
- Operations.Rectangle
- Operations.Flood

- canvas = Canva.apply(canvas, operation)
- ascii_string = Canva.render(canvas)

Now we have minimal blocks to write acceptance tests. Let's create them and see
how they fail.

While I didn't have a confidence in the modules structure, I declare all of 
them in single file or even inside a test. After I'm sure that where will be
no drastical changes, I extract them in appropriate files.

### Defining Canvas module

I want to have ability to compare different fill algorithms and canvas data
holding structures, so I extract a Canvas protocol for that purpose.

Also in order to import types I will declare them distinct modules.

### First Canvas module implementation

For the first implemtation I would go by easiest path. I choose a Map to store
canvas state, and a fill algorithm which recursively goes in four empty directions.

### Splitting canvas from render artifacts

In the future, I want to be able to pass canvas structure for saving, and it is better
to avoid passing where any render artifacts. For that reason, I extract
render and apply functions from the Canvas module to the new RenderContext protocol.
But I still need that convenient structure to store operations and render 
context simultaneously, so let's emerge RenderableCanvas.

### Extracting access behaviour

There is a wide class of fill algorithms that rely on "get/set points" access
behaviour. I have an assumption that using :array module will give us a small 
boost in reading and a lesser memory footprint.

If we talking about here is more performance gain we can get, when
we shall go and try another algorithm for Flood operation, but access implementation
touches all operations, so we start from here.

Also, I want to pass algorithms as parameters to RenderContext as simple
functions, it should help to test them in insolation (but on this stage
my demands are covered with Canva integration test, so I'll use it only
to test some specific edge cases), I will call that RenderContext 
implementation as RenderContexts.Composable
