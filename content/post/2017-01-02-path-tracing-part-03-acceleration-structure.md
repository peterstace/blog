+++
date = "2017-01-02T09:21:37+11:00"
title = "Path Tracing Part 3 - Acceleration Structure"
tags = []
categories = ["Programming", "Golang"]
+++

I recently added an acceleration data structure to my [path
tracer](https://github.com/peterstace/grayt). This resulted in a large
performance improvement.

It does this by improving the performance of the *global ray intersection test*, an
integral part of any path tracer.

The source code can be found [here](TODO).

## Global Ray Intersection Test

The global ray intersection test is the most computationally expensive part of
a path tracer. The test takes a ray, and checks to see if it intersects with
any of the objects in the scene.

A `ray` is defined as an origin `vector` and a (unit) direction `vector`:

```
type vector { x, y, z float64 }

type ray { origin, dir float64 }
```

The object with which to intersect is defined as follows:

```
type object interface {
    intersect(ray) (unitNormal vector, distance float64, hit bool)
}
```

If the `ray` intersects the object, then `intersect(ray)` will return the unit
normal at the hit site, along with the distance to the hit site from the ray
origin.

To calculate the intersection between a ray and all objects in the scene, we
must complete the following code:

```
type dataStructure struct {
    // ...
}

func newDataStructure([]object) *dataStructure {
    // ...
}

func (d *dataStructure) intersect(r ray) (unitNormal vector, distance float64, hit bool) {
    // ...
}
```

There are lots of different ways to implement the global ray intersection test.
The performance characteristics of the global ray intersection test will have a
large impact on the performance of the path tracer as a whole:

* The global ray intersection test has to be executed a large number of times.
  In a path tracer, each ray cast from the camera may spawn 10s of secondary
rays (e.g. reflection rays). So even with a modest image resolution (1000 by
1000 pixels) and a modest sample rate (1000 samples per pixel), it's possible
that upwards to 10 billion ray intersection will be required to render a single
image.

* A single global ray intersection test itself is computationally expensive. It
  must consider all of the objects in the scene. There may be 10s or even 100s
of thousands of objects in the scene.

## Naive Implementation

The naive implementation sequentially checks each object in the scene, keeping
track of the closest intersection found so far. This is easy to implement, but
has the worst possible performance.

```
type objectList struct {
    objs []object
}

func newObjectList(objs []object) *objectList {
    return &objectList{objs}
}

func (o *objectList) intersect(r ray) (unitNormal vector, distance float64, hit bool) {

    closest struct {
        unitNormal vector
        distance   float64
        hit        bool
    }

    for _, obj := range o.objs {
        unitNormal, distance, hit := obj.intersect(r)
        if !hit {
            continue
        }
        if !closest.hit || distance < closest.distance {
            closest.unitNormal = unitNormal
            closest.distance = distance
            closest.hit = true
        }
    }

    return closest.unitNormal, closest.distance, closest.hit
}

```

The main problem with the naive implementation is that it has to check each
object in the scene for an intersection. If we can reduce the amount of
intersection tests with individual objects, we can increase its performance.

## Fast Implementation

A "grid" data structure can allow us to dramatically increase the speed of the
ray intersection test. It does this by cleverly reducing the number of
individual object intersections tests we have to perform.

The algorithm is split into two parts:

1. The data structure is populated using the set of objects in the scene.

2. The data structure is then traversed to solve the global ray intersection
   test.

### Grid Population

First a 3D grid created, the same size as the scene. Each object in the scene
is checked to see which grid cell(s) it falls into. The objects are then stored
into an array representing the grid for fast access. This data structure allows
the list of scene objects in a given grid cell to be looked up in constant
time.

A 2D example is shown below:

TODO: Image

### Grid Traversal

When performing the global ray intersection test, the first step is the find
the cell in the grid that is first hit by the ray. Each scene object in that
cell is then tested for a ray intersection. If any of the objects in that cell
intersect with the ray, then the result of the global ray intersection test is
the intersection with the individual object that's closest to the start of the
ray. If no object is detected, then we continue to the next cell and repeat.
The global ray intersection check finishes when an intersection has been found,
or we have traversed all the way to the other side of the grid.

There's a non-obvious edge case that must be accounted for. An object may be
partially inside a particular cell, and also intersect with a ray. However, the
intersection doesn't occur inside that cell, then we shouldn't count this
intersection.

The algorithm is fast because it's computationally cheap to iterate through the
cells the grid that intersect with the ray. This is done using the BLAH method.

The following is an example of the grid traversal (and matches the grid above):

TODO: Image.

1. The first cell the ray enters is *(0, 3)*. There is a single object in the
   cell, but it doesn't intersect with the ray. So we continue to the next
cell.

2. The next cell the ray enters is *(1, 3)*. There are two objects in the
   cell. The ray doesn't intersect with the small circle. However, there is
also a triangle in the cell (just its small corner). The ray *does* intersect
with the ray, but *not* inside the cell we are currently in (this is the edge
case describe above). We ignore this intersection and continue on to the next
cell.

3. The next cell the ray enters is *(1, 2)*. There are no objects in this cell,
   so we continue to the next cell.

4. The next cell is *(2, 2)*. There are two objects in this cell, both
   intersecting with the ray. The closest intersection is the circle. Since we
have found a valid intersection, the global ray intersection check is complete.

## Performance Improvements and Computational Complexity

The rendering time for my existing scenes was decreased by a factor between 1.5
and 100 (depending on the size scene being rendered). Anecdotally, I found that
the acceleration structure had a bigger impact on scenes containing more
objects (10s or 100s of thousands). For scenes with only a few dozen objects,
the acceleration structure had only a minor effect.

The computational complexity of the naive global ray intersection test is
linear in the number of objects in the scene. This is fairly obvious, since we
iterate through each object in the scene, checking for an intersection. Each
object ray intersection test is constant time on its own.

I haven't performed any formal computational complexity analysis of the grid
algorithm. However, I suspect that the computational complexity is
`O(n^(1/3))`. We are essentially iterating through a one dimensional sequence
of grid cells in a 3 dimensional grid. So we only need to visit around
`m^(1/3)` cells (where `m` is the total number of cells). Assuming that objects
are evenly distributed throughout the cells, it follows that if there are `n`
objects in the scene, then we would only have to perform `O(n^(1/3))`
individual object ray intersect checks in total.
