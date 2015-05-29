angular = require 'angular'
d3 = require 'd3'
require '../../helpers'
_ = require 'lodash'
Data = require './derivativeData'

template = '''
	<svg ng-init='vm.resize()' width='100%' ng-attr-height='{{vm.svg_height}}'>
		<defs>
			<clippath id='derClip'>
				<rect ng-attr-width='{{vm.width}}' ng-attr-height='{{vm.height}}'></rect>
			</clippath>
		</defs>
		<g class='boilerplate' shifter='[vm.mar.left, vm.mar.top]'>
			<rect class='background' ng-attr-width='{{vm.width}}' ng-attr-height='{{vm.height}}' ng-mousemove='vm.move($event)' />
			<g ver-axis-der width='vm.width' scale='vm.V' fun='vm.verAxFun'></g>
			<g hor-axis-der height='vm.height' scale='vm.T' fun='vm.horAxFun' shifter='[0,vm.height]'></g>
			<foreignObject width='30' height='30' y='17' shifter='[vm.width/2, vm.height]'>
					<text class='label' >$t$</text>
			</foreignObject>
		</g>
		<g class='main' clip-path="url(#derClip)" shifter='[vm.mar.left, vm.mar.top]'>
			<line class='zero-line hor' d3-der='{x1: 0, x2: vm.width, y1: vm.V(0), y2: vm.V(0)}'/>
			<path ng-attr-d='{{vm.lineFun(vm.data)}}' class='fun v' />
			<path ng-attr-d='{{vm.triangleData()}}' class='tri' />
			<line class='tri dv' d3-der='{x1: vm.T(vm.point.t)-1, x2: vm.T(vm.point.t)-1, y1: vm.V(vm.point.v), y2: vm.V((vm.point.v + vm.point.dv))}'/>
			<foreignObject width='30' height='30' shifter='[(vm.T(vm.point.t) - 16), vm.sthing]'>
					<text class='tri-label' >$\\dot{y}$</text>
			</foreignObject>
			<circle r='3px'  shifter='[vm.T(vm.point.t), vm.V(vm.point.v)]' class='point v'/>
		</g>
	</svg>
'''
			
class Ctrl
	constructor: (@scope, @el, @window)->
		@mar = 
			left: 30
			top: 20
			right: 20
			bottom: 35

		@V = d3.scale.linear().domain [-1.5,1.5]
		@T = d3.scale.linear().domain [0,6]

		@data = Data.data

		@horAxFun = d3.svg.axis()
			.scale @T
			.ticks 5
			.orient 'bottom'

		@verAxFun = d3.svg.axis()
			.scale @V
			.tickFormat (d)->
				if Math.floor( d ) != d then return
				d
			.ticks 5
			.orient 'left'

		@lineFun = d3.svg.line()
			.y (d)=> @V d.v
			.x (d)=> @T d.t

		angular.element @window
			.on 'resize', @resize

		@move = (event) =>
			t = @T.invert event.x - event.target.getBoundingClientRect().left
			Data.move t
			@scope.$evalAsync()

	@property 'svg_height', get: -> @height + @mar.top + @mar.bottom

	@property 'sthing', get:->
		@V(@point.dv/2 + @point.v) - 7

	@property 'point', get:->
		Data.point

	triangleData:->
		@lineFun [{v: @point.v, t: @point.t}, {v:@point.dv + @point.v, t: @point.t+1}, {v: @point.dv + @point.v, t: @point.t}]

	resize: ()=>
		@width = @el[0].clientWidth - @mar.left - @mar.right
		@height = @el[0].parentElement.clientHeight - @mar.top - @mar.bottom - 8
		@V.range [@height, 0]
		@T.range [0, @width]
		@scope.$evalAsync()

der = ()->
	directive = 
		controllerAs: 'vm'
		scope: {}
		template: template
		templateNamespace: 'svg'
		controller: ['$scope','$element', '$window', Ctrl]

module.exports = der
