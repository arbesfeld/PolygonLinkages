# -*- coding: utf-8 -*-
import argparse
import random
import os
import json
import svgfig as sv
import math

import cherrypy

from ws4py.server.cherrypyserver import WebSocketPlugin, WebSocketTool
from ws4py.websocket import WebSocket
from ws4py.messaging import TextMessage

CIRCLE_RADIUS = 0.3
THICKNESS = 1.5
MULT = 0.06
CANVAS_WIDTH = "4000px"
CANVAS_HEIGHT = "4000px"

IP = '18.111.5.233'
HPI = math.pi /2 

def line(p, color = "red"):
  return sv.Poly(p, mode = "lines", stroke = color).SVG()

def circle(p, a = CIRCLE_RADIUS, color = "black"):
  return sv.Ellipse(p[0], p[1], a, a, math.sqrt(2) * a, stroke_width = 0.2).SVG()

def printPoint(p):
  print str(p[0]) + ", " + str(p[1])

def avg(p1, p2):
  return ( (p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2 )

def getSVGLinkage(len1, len2, angle, ori):
  while angle > 2*math.pi:
    angle -= 2*math.pi
  while angle < 0:
    angle += 2*math.pi
  if angle < 1.5*math.pi and angle > 0.5*math.pi:
    angle = math.pi - math.fabs(angle - math.pi)
  elif angle >= 1.5*math.pi:
    angle = math.fabs(angle - 2*math.pi)
  angle -= HPI
  print("Creating linkage with len 1 = " + str(len1) + " len2 = " + str(len2) + " angle = " + str(angle))
  
  linkage = []

  pBottom = ori
  pBottomLeft = ( pBottom[0] - THICKNESS, pBottom[1] )
  pBottomRight = ( pBottom[0] + THICKNESS, pBottom[1] )

  pCtr = ( pBottom[0], pBottom[1] + len1)
  pTop = ( pCtr[0] + len2 * math.cos(angle), pCtr[1] + len2 * math.sin(angle) )

  if angle > 0:
    # obtuse

    offset = 0.25 * THICKNESS / math.tan(angle) # not sure why 0.25 works here... 

    pCtrRight = ( pCtr[0] + THICKNESS, pCtr[1] - offset)
    
    pCtrLeftLow = ( pCtrRight[0] - 2 * THICKNESS, pCtrRight[1] )
    pCtrLeftHigh = ( pCtrRight[0] - 2 * THICKNESS * math.cos(HPI - angle), pCtrRight[1] + 2 * THICKNESS * math.sin(HPI - angle) )

    pTopLeft = ( pCtrLeftHigh[0] + len2 * math.cos(angle), pCtrLeftHigh[1] + len2 * math.sin(angle) )
    pTopRight = ( pCtrRight[0] + len2 * math.cos(angle), pCtrRight[1] + len2 * math.sin(angle) )

    linkage.append(sv.Curve(lambda t: (-2 * THICKNESS * math.cos(t) + pCtrRight[0], 2 * THICKNESS * math.sin(t) + pCtrRight[1]), 0, HPI - angle).SVG())

  else:
    # acute

    offset = THICKNESS * math.tan( abs(angle) ) + THICKNESS

    pCtrRight = ( pCtr[0] + THICKNESS, pCtr[1] - offset)

    pCtrLeftLow = ( pCtr[0] - THICKNESS, pCtr[1])
    pCtrLeftHigh = ( pCtr[0] - THICKNESS * math.cos(HPI - angle), pCtr[1] + THICKNESS * math.sin(HPI - angle) )

    pTopLeft = ( pCtrLeftHigh[0] + len2 * math.cos(angle), pCtrLeftHigh[1] + len2 * math.sin(angle) )
    pTopRight = ( 2*pTop[0] - pTopLeft[0], 2*pTop[1] - pTopLeft[1] )
    linkage.append(sv.Curve(lambda t: (-THICKNESS * math.cos(t) + pCtr[0], THICKNESS * math.sin(t) + pCtr[1]), 0, HPI - angle).SVG())
  
  linkage.append(line([pBottomLeft, pCtrLeftLow], "black"))
  linkage.append(line([pCtrLeftHigh, pTopLeft], "black"))
  linkage.append(line([pBottomRight, pCtrRight, pTopRight], "black"))

  # pBottomCircle = (ori[0], ori[1] + OVERHANG)
  # pTopCircle = ( pCtr[0] + (len2 - OVERHANG) * math.cos(angle), pCtr[1] + (len2 - OVERHANG) * math.sin(angle) )

  linkage.append(circle(pBottom))
  linkage.append(circle(pCtr))
  linkage.append(circle(pTop))

  linkage.append(sv.Curve(lambda t: (THICKNESS * math.cos(t) + pBottom[0], THICKNESS * math.sin(t) + pBottom[1]), math.pi, 2*math.pi).SVG())

  pTopMid = avg( pTopLeft, pTopRight )
  linkage.append(sv.Curve(lambda t: (THICKNESS * math.cos(t) + pTopMid[0], THICKNESS * math.sin(t) + pTopMid[1]), angle - HPI, angle + HPI).SVG())

  return linkage

def drawSVG(lengths, angles):
  # length is 2xN of floats, angles is 1xN of floats
  sv._canvas_defaults["width"] = CANVAS_WIDTH
  sv._canvas_defaults["height"] = CANVAS_HEIGHT
  N = len(angles)
  sqrtN = math.ceil(math.sqrt(N))

  g = sv.SVG("g")
  offset = (5, 5)
  print sqrtN
  horizontalOffset = 0
  verticalOffset = 0

  for i in range(N):
    horizontalOffset = max( max(horizontalOffset, lengths[0][i] * 1.4), lengths[1][i] * 1.4) 
    verticalOffset = max( max(verticalOffset, lengths[0][i] * 2), lengths[1][i] * 2)
  horizontalOffset *= MULT
  verticalOffset *= MULT
  print "offset = " + str(horizontalOffset) + ", " + str(verticalOffset) 
  for i in range(N):
    linkage = getSVGLinkage(lengths[0][i]*MULT, lengths[1][i]*MULT, angles[i], offset)
    for elem in linkage:
      g.append(elem)
    if i % sqrtN == 0 and i != 0:
      print "Switching rows"
      offset = (5, offset[1] + verticalOffset)
    else:
      offset = (offset[0] + horizontalOffset, offset[1])

  g.save("tmp.svg")

def process(m):
  # JSON with keys Length1, Length2, Angles
  jsonobj = json.loads(m)
  lengths = [jsonobj["Length1"], jsonobj["Length2"]]
  angles = jsonobj["Angles"]
  print lengths
  print angles
  drawSVG(lengths, angles)

class WebSocketHandler(WebSocket):
    def received_message(self, m):
        process(str(m))

    def closed(self, code, reason="A client left."):
        #print "Closed"
        pass

class Root(object):
    def __init__(self, host, port, ssl=False):
        self.host = host
        self.port = port
        self.scheme = 'wss' if ssl else 'ws'

    @cherrypy.expose
    def index(self):
        return "hello"

    @cherrypy.expose
    def ws(self):
        cherrypy.log("Handler created: %s" % repr(cherrypy.request.ws_handler))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Linkage Server')
    parser.add_argument('--host', default=IP)
    parser.add_argument('-p', '--port', default=80, type=int)
    parser.add_argument('--ssl', action='store_true')
    args = parser.parse_args()

    cherrypy.config.update({'server.socket_host': args.host,
                            'server.socket_port': args.port,
                            'tools.staticdir.root': os.path.abspath(os.path.join(os.path.dirname(__file__), 'static'))})

    if args.ssl:
        cherrypy.config.update({'server.ssl_certificate': './server.crt',
                                'server.ssl_private_key': './server.key'})
                            
    WebSocketPlugin(cherrypy.engine).subscribe()
    cherrypy.tools.websocket = WebSocketTool()

    cherrypy.quickstart(Root(args.host, args.port, args.ssl), '', config={
        '/ws': {
            'tools.websocket.on': True,
            'tools.websocket.handler_cls': WebSocketHandler
            },
        # '/js': {
        #       'tools.staticdir.on': True,
        #       'tools.staticdir.dir': 'js'
        #     }
         }
    )
