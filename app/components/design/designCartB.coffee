_ = require 'lodash'
d3= require 'd3'
{min} = Math
require '../../helpers'
Cart = require './trueCart'

template = '''
	<svg ng-init='vm.resize()' width='100%' class='cartChart' ng-attr-height='{{::vm.svgHeight}}'>
		<g shifter='{{::[vm.mar.left, vm.mar.top]}}'>
			<rect d3-der='{width: vm.width, height: vm.height}' class='background'/>
			<g hor-axis-der height='vm.height' scale='vm.X' fun='vm.axisFun' shifter='[0,vm.height]'></g>
			<foreignObject width='30' height='30' y='20' shifter='[vm.width/2, vm.height]'>
					<text class='label' >$x$</text>
			</foreignObject>
			<g class='g-cart' ng-repeat='t in vm.sample' d3-der='{transform: "translate(" + vm.X(vm.Cart.loc(t)) + ",0)"}' style='opacity:.3;'>
				<line class='time-line' d3-der='{x1: 0, x2: 0, y1: 0, y2: 60}' />
			</g>
			<g class='g-cart' d3-der='{transform: "translate(" + vm.X(vm.Cart.x) + ",30)"}' >
				<rect class='cart' x='-12.5' width='25' y='-12.5' height='25'/>
			</g>
		</g>
	</svg>
'''

class Ctrl
	constructor: (@scope, @el, @window)->
		@mar = 
			left: 10
			right: 10
			top: 10
			bottom: 15
			
		@X = d3.scale.linear().domain [-.1,3] 

		@sample = _.range( 0, 5 , .5)

		@Cart = Cart

		@axisFun = d3.svg.axis()
			.scale @X
			.ticks 5
			.orient 'bottom'

		@tran = (tran)->
			tran.ease 'linear'
				.duration 60

		angular.element @window
			.on 'resize' , @resize

	resize: ()=>
		@width = @el[0].clientWidth - @mar.left - @mar.right
		@height = 60
		@X.range [0, @width]
		@scope.$evalAsync()

	@property 'svgHeight', get:-> @height + @mar.top+@mar.bottom

der = ()->
	directive = 
		template: template
		scope: {}
		restrict: 'A'
		bindToController: true
		templateNamespace: 'svg'
		controller: ['$scope', '$element', '$window', Ctrl]
		controllerAs: 'vm'

module.exports = der
