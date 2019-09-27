+++
date = "2017-01-11T21:14:51+11:00"
title = "Panic and Recover as Error Handling Mechanisms in Go"
tags = [ "go", "golang", "idiomatic", "error", "type assertion", "torrent", "decoder" ]
+++

In Go, the generally accepted idiomatic way to handle error conditions is via
the builtin `error` type. In most situations, this leads to clear and easy to
understand error handling code.

This isn't always the case though. When dealing with a large number of type
assertions, panic and recover can lead to elegant and easy to understand code.

I recently came across this sort of situation while writing a decoder for
`.torrent` files.

This blog post will go through a simplified version of the problem, exhibiting
how and why panic and recover allow better code to be crafted in this
particular situation.

## The Problem

A `.torrent` file consists of an encoded `Value`. In general, a `Value` can
either be an `int`, a `string`, or a `map[string]Value`:

```
// Value is either `int`, `string`, or `map[string]Value`.
type Value interface{}
```

However, `Value`s that are encoded inside `.torrent` files will contain very
specific structures (the `.torrent` structure given here is a simplified
version of reality. For the full details of real `.torrent` files, the spec can
be found [here](http://bittorrent.org/beps/bep_0003.html)).

The top level `Value` in a `.torrent` file is a `map[string]Value`. It has two
keys, `"announce"` and `"info"`. The `"announce"` value is a `string`, which is
the announce URL of the torrent's tracker. The `"info"` value is another
`map[string]Value`. This map also has two keys, `"name"` and `"piece length"`.
The `"name"` value contains a `string`, which is the suggested name of the
torrent.  The `"piece length"` value contains an `int`, which is the number of
bytes in each torrent piece.

The task is to take the top level `Value`, and extract it into the following
type:

```
type MetaInfo struct {
    AnnounceURL string
    Name        string
    PieceLength int
}
```

Missing keys or incorrect types are errors. Extra keys should be ignored (since
they might be file format extensions).

## Solution A (traditional error handling)

The traditional approach is to use checked type assertions, returning an error
if the type assertion fails.

```
func DecodeMetaInfo(v Value) (MetaInfo, error) {

    var m MetaInfo
    err := errors.New("invalid meta info")

    topLevelMap, ok := v.(map[string]Value)
    if !ok {
        return m, err
    }
    if m.AnnounceURL, ok = topLevelMap["announce"].(string); !ok {
        return m, err
    }
    infoMap, ok := topLevelMap["info"].(map[string]Value)
    if !ok {
        return m, err
    }
    if m.Name, ok = infoMap["name"].(string); !ok {
        return m, err
    }
    if m.PieceLength, ok = infoMap["piece length"].(int); !ok {
        return m, err
    }
    return m, nil
}
```
 
## Solution B (panic and recover)

An alternate solution is to use `recover()` to check for any panics, and then
use non-checked type assertions. This automatically takes care of the error
cases if the type assertions fail.

```
func DecodeMetaInfo(v Value) (m MetaInfo, err error) {

    defer func() {
        if r := recover(); r != nil {
            err = errors.New("invalid meta info")
        }
    }()

    topLevelMap := v.(map[string]Value)
    m.AnnounceURL = topLevelMap["announce"].(string)
    infoMap := topLevelMap["info"].(map[string]Value)
    m.Name = infoMap["name"].(string)
    m.PieceLength = infoMap["piece length"].(int)
    return m, nil
}
```

## Comparison

While the line count between the two solutions isn't dramatically different, I
think the second is much easier to read once familiar with the panic and
recover pattern. The logic isn't cluttered with error handling like it is in
the first solution.

The downside to the second solution is that it's impossible to provide a custom
error value for each error case. For my purposes, this didn't really matter.
The end user of the program isn't going to be able to 'fix' a torrent if it's
not well formed, they just need to know that it cannot be loaded.
