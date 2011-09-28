package com.li.minimole.core
{
import com.li.minimole.camera.Camera3D;

import com.li.minimole.core.render.DefaultRenderer;
import com.li.minimole.core.render.RenderBase;
import com.li.minimole.core.vo.RGB;

import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.events.Event;
import flash.geom.Rectangle;

/*
    Wraps a Scene3D and a Camera3D and manages 3D rendering.
 */
public class View3D extends Sprite
{
    // TODO: Does not yet support stage dims change.

    private var _camera:Camera3D;
    private var _scene:Scene3D;
    private var _canvasWidth:Number;
    private var _canvasHeight:Number;
    private var _aspectRatio:Number;
    private var _context3d:Context3D;
    private var _stage3d:Stage3D;
    private var _textureLayersHolder:Sprite;
    private var _renderer:RenderBase;

    private var _clearColor:RGB = new RGB(0.25, 0.25, 0.25);

    public function View3D()
    {
        super();

        _scene = new Scene3D();
        _camera = new Camera3D();

        // Connect core to view.
        Core3D.instance.view = this;

        _textureLayersHolder = new Sprite();
        _textureLayersHolder.mouseEnabled = _textureLayersHolder.mouseChildren = false;
        addChild(_textureLayersHolder);

        addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
    }

    private function stageInitHandler(evt:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);

        // Set canvas to stage dims.
        _canvasWidth = stage.stageWidth;
        _canvasHeight = stage.stageHeight;
        _aspectRatio = _canvasWidth/_canvasHeight;

        // Init projection matrix.
        _camera.lens.aspectRatio = _aspectRatio;
        _camera.viewWidth = _canvasWidth; // Needed for un-projection.
        _camera.viewHeight = _canvasHeight;

        // Init stage 3d.
        stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3dCreatedHandler);
        stage.stage3Ds[0].requestContext3D();
        stage.stage3Ds[0].x = 0;
		stage.stage3Ds[0].y = 0;
    }

    private function context3dCreatedHandler(evt:Event):void
    {
        // Get stage 3d.
        _stage3d = Stage3D(evt.currentTarget);
        _context3d = _stage3d.context3D;

        // Alert if context3d fetch failed.
        if(_context3d == null)
            throw new Error("Unable to get Context3D.");

        // Init context3d.
        _context3d.enableErrorChecking = true;
        _context3d.configureBackBuffer(_canvasWidth, _canvasHeight, Core3D.instance.antiAlias, true);

        // Report context 3d to all elements that need it.
        // Scene3D takes care of distributing the reference.
        _scene.context3d = _context3d;
    }

    public function render():void
    {
        if(!_renderer)
            _renderer = new DefaultRenderer();

        if(!_renderer.view)
            _renderer.view = this;

        _renderer.render();
    }

    public function get scene():Scene3D
    {
        return _scene;
    }

    public function get camera():Camera3D
    {
        return _camera;
    }

    public function get canvasWidth():Number
    {
        return _canvasWidth;
    }

    public function get canvasHeight():Number
    {
        return _canvasHeight;
    }

    public function get clearColor():RGB
    {
        return _clearColor;
    }

    public function set clearColor(value:RGB):void
    {
        _clearColor = value;
    }

    public function get context3d():Context3D
    {
        return _context3d;
    }

    public function get renderer():RenderBase
    {
        return _renderer;
    }

    public function set renderer(value:RenderBase):void
    {
        _renderer = value;
    }

    public function get aspectRatio():Number
    {
        return _aspectRatio;
    }
}
}
