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

It's great that we have already had acceptance tests in the assignment, we just
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

If it was possible, I would propose to the team to name the Canvas, a CanvasDocument,
or just a Document, to avoid names clash with canvas related to rendering
which does not care about its `id` or storing capabilities. But in many areas
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

While I didn't have confidence in the modules structure, I declared all of 
them in a single file or even inside a test. After I'm sure that there will not be
drastical changes, I extract them in appropriate files.

### Defining Canvas module

I want to have an ability to compare different fill algorithms and canvas data
holding structures, so I extract a Canvas protocol for that purpose.

Also in order to import types I will declare them in distinct modules.

### First Canvas module implementation

For the first implemtation I would go by the easiest path. I chose a Map to store
canvas state, and a filled algorithm which recursively went in four empty directions.

### Splitting canvas from render artifacts

In the future, I want to be able to pass canvas structure for saving, and it is better
to avoid passing there any render artifacts. For that reason, I extract
render and apply functions from the Canvas module to the new RenderContext protocol.
But I still need that convenient structure to store operations and render 
context simultaneously, so let's emerge RenderableCanvas.

### Extracting access behaviour

There is a wide class of fill area algorithms that rely on "get/set points" access
behaviour. I have an assumption that using :array module will give us a small 
boost in reading and a lesser memory footprint.

If we are talking about the performance we can get, then
we shall go and try another algorithm for Flood operation, but access implementation
touches all the operations, therefore we start from here.

Also I want to pass algorithms as parameters to RenderContext as simple
functions, it should help to test them in insolation (but on this stage
my demands are covered with Canva integration test, so I'll use it only
to test some specific edge cases), I will call that RenderContext 
implementation as RenderContexts.Composable

### Adding alternative canvas data structure implementation

We added all preparation work to easily add a new variant to represent points. 
It will be based on :array, so call it ArrayPoints.

We already have had tests for its behaviour, therefore reuse them.

I'm planning to write some data generation functions for a future benchmark.
And I saw a flaw in the Canva module api - there is no function we can pass
bare Canvas module to apply and render it, that is because we hid
building Canvas behind functions describing render strategy. Let's split
these functions to give an ability to explicitly pass bare canvas and its
strategy.

### Testing performance assumption

We need to look at how implementations will behave in different conditions.
Let's benchmark for rendering canvases with different properties: 

  - small is containing 30-100 operations and 
    big is containing 1000 - 10000 operations
  - narrow with 100-1000 points widthwise and 
    wide with 1000-10000 points.

Run `mix benchmark`

As expected the map version is ~1.3x slower and consumes ~1.29x memory more
than the array version. The map version becomes slower with a bigger canvas size
but negligible.

### Deciding that to do next

I have plans to do:

  - add a tail recursive flood algorithm version
  - add a scanning line flood algorithm version
  - add a renderer not based on points but, tree-based.

But I also want to add persistence layer and a web-interface, so I would
rather go in that direction

### Persistense layer

When we started our journey I wrote what I decided to store canvases in files.
I will describe an interface to save files in order to ease testing
of future features, and it will give ability to exchange implementation 
for s3 for example.

### Implementing CanvaFiles

First of all we describe desired behaviour in test. That will be a
recursive definition - we want to recieve the same canvas struct that we stored
earlier.

### Implementing CanvaService

Usually Canva module would contain a service logic and CanvaWeb
will be a web-interface.

But the Canva name is busy by our rendering library.

So let's add two applications:

  - `:canva_service` - implementing actual user actions. 
     Depends on :canva and :canva_files apps.
  - `:canva_service_web` - implementing a web-interface for :canva_service. 

We have no iteractions with database, therefore use --no-ecto and 
--no-gettext flags in builder.

On the main page I want to see the list of links of canvases ids. Which will be
updated if a new one appears. Easiest path to support a live updates will
be a Live View. That whould be the starting point.

When writing assertions on some text or html strings, I avoid to hard code
them in the test, instead I use the same view helpers that building these strings
and use them in test. It helps to make tests less brittle in the face of
changing a non-essential text.

### Implementing live update

In order to get a live update, we need to subscribe for `canvas_updated`
events. Easiest and robust option use Phoenix.PubSub or Registry.
We already have a phoenix pub sub in our supervisor tree, so let's use it.

Inside CanvaService.add_operation we will be sending `canvas_updated`
into topic `canvas:<id>`. in the LiveView mount we subscibe on the topic, 
in handle_info we request new data.

We could do some optimizations with cache to prevent reading
same file twice in short amout of time, but not now.

### Last thoughts

As more time invested the more interesting details come up along the way.
I've tried to make this journey interesting to me, from these intententions
we saw a canvas module with ability to change render strategies.
