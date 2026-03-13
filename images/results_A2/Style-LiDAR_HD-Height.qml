<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.44.7-Solothurn" hasScaleBasedVisibilityFlag="0" minScale="100000000" autoRefreshTime="0" sync3DRendererTo2DRenderer="1" autoRefreshMode="Disabled" maxScale="0" styleCategories="AllStyleCategories">
  <renderer-3d layer="" max-screen-error="3" type="pointcloud" zoom-out-behavior="RenderExtents" point-budget="5000000" show-bounding-boxes="0">
    <symbol render-as-triangles="0" horizontal-triangle-filter="0" point-size="3" color-ramp-shader-max="4000" horizontal-filter-threshold="10" rendering-parameter="Intensity" color-ramp-shader-min="59" type="color-ramp" vertical-filter-threshold="10" vertical-triangle-filter="0">
      <colorrampshader classificationMode="1" clip="0" minimumValue="59" labelPrecision="4" colorRampType="INTERPOLATED" maximumValue="4000">
        <colorramp name="[source]" type="gradient">
          <Option type="Map">
            <Option name="color1" value="5,5,5,255,rgb:0.0196078,0.0196078,0.0196078,1" type="QString"/>
            <Option name="color2" value="250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1" type="QString"/>
            <Option name="direction" value="cw" type="QString"/>
            <Option name="discrete" value="0" type="QString"/>
            <Option name="rampType" value="gradient" type="QString"/>
            <Option name="spec" value="rgb" type="QString"/>
          </Option>
        </colorramp>
        <item color="#050505" value="59" label="59,0000" alpha="255"/>
        <item color="#fafafa" value="4000" label="4000,0000" alpha="255"/>
        <rampLegendSettings minimumLabel="" useContinuousLegend="1" suffix="" orientation="2" maximumLabel="" prefix="" direction="0">
          <numericFormat id="basic">
            <Option type="Map">
              <Option name="decimal_separator" type="invalid"/>
              <Option name="decimals" value="0" type="int"/>
              <Option name="rounding_type" value="0" type="int"/>
              <Option name="show_plus" value="false" type="bool"/>
              <Option name="show_thousand_separator" value="true" type="bool"/>
              <Option name="show_trailing_zeros" value="false" type="bool"/>
              <Option name="thousand_separator" type="invalid"/>
            </Option>
          </numericFormat>
        </rampLegendSettings>
      </colorrampshader>
    </symbol>
  </renderer-3d>
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <elevation zscale="1" respect_layer_colors="1" zoffset="0" point_symbol="Square" max_screen_error_unit="MM" point_size_unit="MM" point_size="0.59999999999999998" point_color="190,207,80,255,rgb:0.745098,0.8117647,0.3137255,1" max_screen_error="0.29999999999999999" opacity_by_distance="0">
    <data-defined-properties>
      <Option type="Map">
        <Option name="name" value="" type="QString"/>
        <Option name="properties"/>
        <Option name="type" value="collection" type="QString"/>
      </Option>
    </data-defined-properties>
  </elevation>
  <renderer renderAsTriangles="0" min="59" pointSizeMapUnitScale="3x:0,0,0,0,0,0" horizontalTriangleFilterUnit="MM" horizontalTriangleFilterThreshold="5" pointSizeUnit="RenderMetersInMapUnits" maximumScreenError="0.29999999999999999" horizontalTriangleFilter="0" pointSymbol="1" type="ramp" drawOrder2d="1" attribute="Intensity" max="4000" pointSize="0.5" maximumScreenErrorUnit="MM">
    <colorrampshader classificationMode="1" clip="0" minimumValue="59" labelPrecision="4" colorRampType="INTERPOLATED" maximumValue="4000">
      <colorramp name="[source]" type="gradient">
        <Option type="Map">
          <Option name="color1" value="5,5,5,255,rgb:0.0196078,0.0196078,0.0196078,1" type="QString"/>
          <Option name="color2" value="250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1" type="QString"/>
          <Option name="direction" value="cw" type="QString"/>
          <Option name="discrete" value="0" type="QString"/>
          <Option name="rampType" value="gradient" type="QString"/>
          <Option name="spec" value="rgb" type="QString"/>
        </Option>
      </colorramp>
      <item color="#050505" value="59" label="59,0000" alpha="255"/>
      <item color="#fafafa" value="4000" label="4000,0000" alpha="255"/>
      <rampLegendSettings minimumLabel="" useContinuousLegend="1" suffix="" orientation="2" maximumLabel="" prefix="" direction="0">
        <numericFormat id="basic">
          <Option type="Map">
            <Option name="decimal_separator" type="invalid"/>
            <Option name="decimals" value="0" type="int"/>
            <Option name="rounding_type" value="0" type="int"/>
            <Option name="show_plus" value="false" type="bool"/>
            <Option name="show_thousand_separator" value="true" type="bool"/>
            <Option name="show_trailing_zeros" value="false" type="bool"/>
            <Option name="thousand_separator" type="invalid"/>
          </Option>
        </numericFormat>
      </rampLegendSettings>
    </colorrampshader>
  </renderer>
  <customproperties>
    <Option/>
  </customproperties>
  <blendMode>0</blendMode>
  <layerOpacity>1</layerOpacity>
</qgis>
