<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" minScale="100000000" sync3DRendererTo2DRenderer="1" styleCategories="AllStyleCategories" autoRefreshMode="Disabled" autoRefreshTime="0" hasScaleBasedVisibilityFlag="0" version="3.44.7-Solothurn">
  <renderer-3d layer="" zoom-out-behavior="RenderExtents" type="pointcloud" point-budget="5000000" max-screen-error="3" show-bounding-boxes="0">
    <symbol vertical-filter-threshold="10" render-as-triangles="0" point-size="3" color-ramp-shader-max="3000" type="color-ramp" vertical-triangle-filter="0" horizontal-filter-threshold="10" rendering-parameter="Intensity" color-ramp-shader-min="58" horizontal-triangle-filter="0">
      <colorrampshader clip="0" maximumValue="3000" colorRampType="INTERPOLATED" classificationMode="1" minimumValue="58" labelPrecision="4">
        <colorramp name="[source]" type="gradient">
          <Option type="Map">
            <Option name="color1" type="QString" value="5,5,5,255,rgb:0.0196078,0.0196078,0.0196078,1"/>
            <Option name="color2" type="QString" value="250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1"/>
            <Option name="direction" type="QString" value="cw"/>
            <Option name="discrete" type="QString" value="0"/>
            <Option name="rampType" type="QString" value="gradient"/>
            <Option name="spec" type="QString" value="rgb"/>
          </Option>
        </colorramp>
        <item label="58,0000" color="#050505" alpha="255" value="58"/>
        <item label="3000,0000" color="#fafafa" alpha="255" value="3000"/>
        <rampLegendSettings prefix="" maximumLabel="" suffix="" orientation="2" minimumLabel="" useContinuousLegend="1" direction="0">
          <numericFormat id="basic">
            <Option type="Map">
              <Option name="decimal_separator" type="invalid"/>
              <Option name="decimals" type="int" value="0"/>
              <Option name="rounding_type" type="int" value="0"/>
              <Option name="show_plus" type="bool" value="false"/>
              <Option name="show_thousand_separator" type="bool" value="true"/>
              <Option name="show_trailing_zeros" type="bool" value="false"/>
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
  <elevation point_size_unit="MM" point_symbol="Square" point_size="0.59999999999999998" zoffset="0" opacity_by_distance="0" point_color="190,207,80,255,rgb:0.745098,0.8117647,0.3137255,1" zscale="1" max_screen_error="0.29999999999999999" max_screen_error_unit="MM" respect_layer_colors="1">
    <data-defined-properties>
      <Option type="Map">
        <Option name="name" type="QString" value=""/>
        <Option name="properties"/>
        <Option name="type" type="QString" value="collection"/>
      </Option>
    </data-defined-properties>
  </elevation>
  <renderer renderAsTriangles="0" pointSymbol="1" maximumScreenErrorUnit="MM" horizontalTriangleFilterUnit="MM" pointSizeMapUnitScale="3x:0,0,0,0,0,0" pointSizeUnit="MM" maximumScreenError="0.29999999999999999" type="ramp" pointSize="1" drawOrder2d="1" max="3000" attribute="Intensity" horizontalTriangleFilterThreshold="5" min="58" horizontalTriangleFilter="0">
    <colorrampshader clip="0" maximumValue="3000" colorRampType="INTERPOLATED" classificationMode="1" minimumValue="58" labelPrecision="4">
      <colorramp name="[source]" type="gradient">
        <Option type="Map">
          <Option name="color1" type="QString" value="5,5,5,255,rgb:0.0196078,0.0196078,0.0196078,1"/>
          <Option name="color2" type="QString" value="250,250,250,255,rgb:0.9803922,0.9803922,0.9803922,1"/>
          <Option name="direction" type="QString" value="cw"/>
          <Option name="discrete" type="QString" value="0"/>
          <Option name="rampType" type="QString" value="gradient"/>
          <Option name="spec" type="QString" value="rgb"/>
        </Option>
      </colorramp>
      <item label="58,0000" color="#050505" alpha="255" value="58"/>
      <item label="3000,0000" color="#fafafa" alpha="255" value="3000"/>
      <rampLegendSettings prefix="" maximumLabel="" suffix="" orientation="2" minimumLabel="" useContinuousLegend="1" direction="0">
        <numericFormat id="basic">
          <Option type="Map">
            <Option name="decimal_separator" type="invalid"/>
            <Option name="decimals" type="int" value="0"/>
            <Option name="rounding_type" type="int" value="0"/>
            <Option name="show_plus" type="bool" value="false"/>
            <Option name="show_thousand_separator" type="bool" value="true"/>
            <Option name="show_trailing_zeros" type="bool" value="false"/>
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
