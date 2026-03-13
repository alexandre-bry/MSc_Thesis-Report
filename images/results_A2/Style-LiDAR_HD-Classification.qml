<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.44.7-Solothurn" hasScaleBasedVisibilityFlag="0" minScale="100000000" autoRefreshTime="0" sync3DRendererTo2DRenderer="1" autoRefreshMode="Disabled" maxScale="0" styleCategories="AllStyleCategories">
  <renderer-3d layer="" max-screen-error="3" type="pointcloud" zoom-out-behavior="RenderExtents" point-budget="5000000" show-bounding-boxes="0">
    <symbol render-as-triangles="0" horizontal-triangle-filter="0" point-size="3" horizontal-filter-threshold="10" rendering-parameter="Classification" type="classification" vertical-filter-threshold="10" vertical-triangle-filter="0">
      <categories>
        <category color="170,170,170,255,rgb:0.6666667,0.6666667,0.6666667,1" value="1" label="Unassigned" pointSize="0" render="true"/>
        <category color="170,85,0,255,rgb:0.6666667,0.3333333,0,1" value="2" label="Ground" pointSize="0" render="true"/>
        <category color="0,170,170,255,rgb:0,0.6666667,0.6666667,1" value="3" label="Low vegetation" pointSize="0" render="true"/>
        <category color="85,255,85,255,rgb:0.3333333,1,0.3333333,1" value="4" label="Medium vegetation" pointSize="0" render="true"/>
        <category color="0,170,0,255,rgb:0,0.6666667,0,1" value="5" label="High vegetation" pointSize="0" render="true"/>
        <category color="255,85,85,255,rgb:1,0.3333333,0.3333333,1" value="6" label="Building" pointSize="0" render="true"/>
        <category color="255,158,23,255,rgb:1,0.6196078,0.0901961,1" value="64" label="Permanent overground" pointSize="0" render="true"/>
        <category color="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" value="65" label="Virtual points" pointSize="0" render="true"/>
        <category color="141,90,153,255,rgb:0.5529412,0.3529412,0.6,1" value="67" label="Miscellaneous buildings" pointSize="0" render="true"/>
      </categories>
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
  <renderer renderAsTriangles="0" pointSizeMapUnitScale="3x:0,0,0,0,0,0" horizontalTriangleFilterUnit="MM" horizontalTriangleFilterThreshold="5" pointSizeUnit="RenderMetersInMapUnits" maximumScreenError="0.29999999999999999" horizontalTriangleFilter="0" pointSymbol="1" type="classified" drawOrder2d="1" attribute="Classification" pointSize="0.5" maximumScreenErrorUnit="MM">
    <categories>
      <category color="170,170,170,255,rgb:0.6666667,0.6666667,0.6666667,1" value="1" label="Unassigned" pointSize="0" render="true"/>
      <category color="170,85,0,255,rgb:0.6666667,0.3333333,0,1" value="2" label="Ground" pointSize="0" render="true"/>
      <category color="0,170,170,255,rgb:0,0.6666667,0.6666667,1" value="3" label="Low vegetation" pointSize="0" render="true"/>
      <category color="85,255,85,255,rgb:0.3333333,1,0.3333333,1" value="4" label="Medium vegetation" pointSize="0" render="true"/>
      <category color="0,170,0,255,rgb:0,0.6666667,0,1" value="5" label="High vegetation" pointSize="0" render="true"/>
      <category color="255,85,85,255,rgb:1,0.3333333,0.3333333,1" value="6" label="Building" pointSize="0" render="true"/>
      <category color="255,158,23,255,rgb:1,0.6196078,0.0901961,1" value="64" label="Permanent overground" pointSize="0" render="true"/>
      <category color="232,113,141,255,rgb:0.9098039,0.4431373,0.5529412,1" value="65" label="Virtual points" pointSize="0" render="true"/>
      <category color="141,90,153,255,rgb:0.5529412,0.3529412,0.6,1" value="67" label="Miscellaneous buildings" pointSize="0" render="true"/>
    </categories>
  </renderer>
  <customproperties>
    <Option/>
  </customproperties>
  <blendMode>0</blendMode>
  <layerOpacity>1</layerOpacity>
</qgis>
