#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4"
#import cetz-plot.plot

#let content(..args) = plot.annotate(cetz.draw.content(..args))
#let line(..args) = plot.annotate(cetz.draw.line(..args))
#let circle(..args) = plot.annotate(cetz.draw.circle(..args))
#let rect(..args) = plot.annotate(cetz.draw.rect(..args))
#let angle(..args) = plot.annotate(cetz.angle.angle(..args))
#let right-angle(..args) = plot.annotate(cetz.angle.right-angle(..args))
#let brace(..args) = plot.annotate(cetz.decorations.brace(..args))

#import "/utils/complex.typ": *
#import "drawing.typ": *
#import "functions.typ": *
#import "analysis.typ": *
#import "graph.typ": graph
