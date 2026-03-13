<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" minScale="100000000" sync3DRendererTo2DRenderer="1" styleCategories="AllStyleCategories" autoRefreshMode="Disabled" autoRefreshTime="0" hasScaleBasedVisibilityFlag="0" version="3.44.7-Solothurn">
  <renderer-3d layer="" zoom-out-behavior="RenderExtents" type="pointcloud" point-budget="5000000" max-screen-error="3" show-bounding-boxes="0">
    <symbol vertical-filter-threshold="10" render-as-triangles="0" point-size="3" type="classification" vertical-triangle-filter="0" horizontal-filter-threshold="10" rendering-parameter="Classification" horizontal-triangle-filter="0">
      <categories>
        <category label="Unassigned" render="true" pointSize="0" color="170,170,170,255,rgb:0.6666667,0.6666667,0.6666667,1" value="1"/>
        <category label="Ground" render="true" pointSize="0" color="170,85,0,255,rgb:0.6666667,0.3333333,0,1" value="2"/>
        <category label="Low vegetation" render="true" pointSize="0" color="0,170,170,255,rgb:0,0.6666667,0.6666667,1" value="3"/>
        <category label="Medium vegetation" render="true" pointSize="0" color="85,255,85,255,rgb:0.3333333,1,0.3333333,1" value="4"/>
        <category label="High vegetation" render="true" pointSize="0" color="0,170,0,255,rgb:0,0.6666667,0,1" value="5"/>
        <category label="Building" render="true" pointSize="0" color="255,85,85,255,rgb:1,0.3333333,0.3333333,1" value="6"/>
        <category label="Permanent overground" render="true" pointSize="0" color="255,158,23,255,rgb:1,0.6196078,0.0901961,1" value="64"/>
        <category label="Virtual points" render="true" pointSize="0" color="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" value="65"/>
        <category label="Miscellaneous buildings" render="true" pointSize="0" color="141,90,153,255,rgb:0.5529412,0.3529412,0.6,1" value="67"/>
      </categories>
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
  <renderer renderAsTriangles="0" pointSymbol="1" maximumScreenErrorUnit="MM" horizontalTriangleFilterUnit="MM" pointSizeMapUnitScale="3x:0,0,0,0,0,0" pointSizeUnit="MM" maximumScreenError="0.29999999999999999" type="classified" pointSize="1" drawOrder2d="1" attribute="Classification" horizontalTriangleFilterThreshold="5" horizontalTriangleFilter="0">
    <categories>
      <category label="Unassigned" render="true" pointSize="0" color="170,170,170,255,rgb:0.6666667,0.6666667,0.6666667,1" value="1"/>
      <category label="Ground" render="true" pointSize="0" color="170,85,0,255,rgb:0.6666667,0.3333333,0,1" value="2"/>
      <category label="Low vegetation" render="true" pointSize="0" color="0,170,170,255,rgb:0,0.6666667,0.6666667,1" value="3"/>
      <category label="Medium vegetation" render="true" pointSize="0" color="85,255,85,255,rgb:0.3333333,1,0.3333333,1" value="4"/>
      <category label="High vegetation" render="true" pointSize="0" color="0,170,0,255,rgb:0,0.6666667,0,1" value="5"/>
      <category label="Building" render="true" pointSize="0" color="255,85,85,255,rgb:1,0.3333333,0.3333333,1" value="6"/>
      <category label="Permanent overground" render="true" pointSize="0" color="255,158,23,255,rgb:1,0.6196078,0.0901961,1" value="64"/>
      <category label="Virtual points" render="true" pointSize="0" color="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" value="65"/>
      <category label="Miscellaneous buildings" render="true" pointSize="0" color="141,90,153,255,rgb:0.5529412,0.3529412,0.6,1" value="67"/>
    </categories>
  </renderer>
  <customproperties>
    <Option/>
  </customproperties>
  <blendMode>0</blendMode>
  <layerOpacity>1</layerOpacity>
</qgis>
