+++
date = "2016-12-20T19:55:41+11:00"
title = "Path Tracing Part 1 - Initial Renders"
categories = ["Development", "Golang"]
tags = ["grayt", "go", "golang", "ray tracer", "path tracer", "side project",
"photo realistic", "render", "diffuse", "reflection", "matte", "cornell box"]
+++

## Enter Grayt

[Grayt](https://github.com/peterstace/grayt) (**G**o **Ray** **T**racer) was a
project that I started in mid 2014 to help me learn [Go](https://golang.org).
As the name suggests, it started out as a [ray
tracer](https://en.wikipedia.org/wiki/Ray_tracing_(graphics)). Having
implemented ray tracers before (in C++), this was quite straight forward but
ultimately wasn't very satisfying.  I still wanted a side project to learn Go
with, so I pivoted it from a ray tracer to a [path
tracer](https://en.wikipedia.org/wiki/Path_tracing).  Path tracers are much
harder to implement, and produce more realistic renderings. The name "Grayt"
stuck, even if it's no longer a truly accurate name.

At its core, a path tracer takes a mathematical description of a 3D scene and
renders it, producing a 2D image. They're able to render highly photo realistic
images by simulating light related physical phenomena that occur in the real
wold.

Currently, Grayt only supports diffuse reflections. These types of reflections
are only a tiny subset of the reflections that occur in the real world.
However, they allow a path tracer to render matte objects with relative
accuracy.

## Renders

I started out with 3 different renderings, each showing off different aspects
of the path tracer.

### Cornell Box

The first scene I implemented is the classic [Cornell
Box](https://en.wikipedia.org/wiki/Cornell_box), originally created at Cornell
University as a 3D test model. My take on the Cornell Box is slightly different
from the original.

The rendering contains:

* A red 'left' wall.
* A green 'right' wall.
* A white floor and ceiling.
* A white ceiling light.
* Two white blocks.

All surfaces are matte. A real wold example of a matte surface would be a
non-glossy and slightly rough painted surface.

In the rendering, you can observer:

* Soft shadows being cast by the blocks onto the floor.
* Green and red light being reflected off the green and red walls onto the
  white center blocks.
* Occlusion shadows, most visible in the back top corners of the room.

In a traditional ray tracer, these three effects must be implemented as special
cases (and it's very hard to do so accurately). In path tracing however, we get
them 'for free' by virtue of having implemented diffuse reflections.

![Cornell Box](/static/images/cornell_box.png)

### Split Box

My second rendering is of a procedurally generated scene of my own design.  I
started by taking a cube and splitting it into two pieces along a random axis.
I then moved each piece slightly against the other. I repeated this on the
remaining cubes over several dozen iterations. The cube stricture is white, and
is situated underneath a white light. Like the Cornell Box, there are coloured
walls to the left and right (off camera) that reflect coloured light into the
scene.

![Split Box](/static/images/split_box.png)

### Sphere Tree

My third rendering is also of a procedurally generated scene of my own design.
I created a 'tree' structure out of spheres. I started with a large sphere
centered in the floor, and randomly added two 'child' spheres to its surface. I
then added two more child spheres to each of the original child spheres. This
continued until I had several hundred spheres.

![Sphere Tree](/static/images/sphere_tree.png)
