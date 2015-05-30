_ = require 'lodash'
require '../../helpers'
Cart = require '../cart/cartData'
{exp, min, max} = Math

vScale = d3.scale.linear()
xScale = d3.scale.linear()

class Dot
	constructor: (@t, @v)->
		@id = _.uniqueId 'dot'
		@hilited = false

class Data
	constructor: ->
		@t = @x = 0
		firstDot = new Dot 0 , Cart.v0
		firstDot.id = 'first'
		@dots = [ firstDot, 
			new Dot Cart.trajectory[10].t , Cart.trajectory[10].v
		]
		@correct = @show = false
		@first = @selected = firstDot
		@target_data = Cart.trajectory

		@data = _.range 0, 6, 1/50
			.map (t)->
				res = 
					t: t
					v: 0
					x: 0
				
		xScale.domain _.pluck @data, 't'
		@update_dots()

		@sample = _.range 0 , 10
			.map (n)=>
				@data[n*30]

		@true_sample = _.range 0 , 10
			.map (n)=>
				Cart.trajectory[n*30]

	add_dot: (t, v)->
		@selected = new Dot t,v
		@dots.push @selected
		@update_dot @selected, t, v

	remove_dot: (dot)->
		@dots.splice @dots.indexOf(dot), 1
		@update_dots()

	update_dots: -> 
		@dots.sort (a,b)-> a.t - b.t
		@dots.forEach (dot, i, k)->
			prev = k[i-1]
			if prev
				dt = dot.t - prev.t
				dot.x = prev.x + dt * (dot.v + prev.v)/2
				dot.dv = (dot.v - prev.v)/max(dt, .0001)
			else
				dot.x = 0
				dot.dv = 0
		domain = _.pluck @dots, 't'
		domain.push 6.5
		range = _.pluck  @dots , 'v'
		range.push @dots[@dots.length - 1].v
		vScale.domain domain
			.range range

		@data.forEach (d,i,k)->
			d.v = vScale d.t
			if i > 0
				prev = k[i-1]
				d.x = prev.x + (prev.v + d.v)/2*(d.t-prev.t)
			else
				d.x = 0

		xScale.range _.pluck @data, 'x'


	update_dot: (dot, t, v)->
		if dot.id == 'first' then return
		@selected = dot
		dot.t = t
		dot.v = v
		@update_dots()
		@correct = Math.abs(Cart.k * @selected.v + @selected.dv) < 0.05

	@property 'x', get: ->
		res = xScale @t

	@property 'true_x', get: ->
		_.findLast Cart.trajectory, (d)=> 
				d.t <= @t
			.x

	@property 'maxX', get:->
		3

module.exports = new Data