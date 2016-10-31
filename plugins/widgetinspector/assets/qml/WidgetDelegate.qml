/*
  WidgetDelegate.qml

  This file is part of GammaRay, the Qt application inspection and
  manipulation tool.

  Copyright (C) 2011-2016 Klarälvdalens Datakonsult AB, a KDAB Group company, info@kdab.com
  Author: Daniel Vrátil <daniel.vratil@kdab.com>

  Licensees holding valid commercial KDAB GammaRay licenses may use this file in
  accordance with GammaRay Commercial License Agreement provided with the Software.

  Contact info@kdab.com if any conditions of this licensing are not clear to you.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Extras 2.0
import QtQuick 2.5 as QQ2


Entity {
    id: root;

    property rect topLevelGeometry
    property real explosionFactor: 0
    property string objectId
    property var metaData
    property bool isWindow : false

    property int depth
    property var frontTextureImage
    property var backTextureImage
    property rect geometry
    property bool selected : objectPicker.containsMouse

    readonly property real _scaleFactor : 10.0
    readonly property real _geomWidth: root.geometry.width / _scaleFactor
    readonly property real _geomHeight: root.geometry.height / _scaleFactor
    readonly property real _geomX: root.geometry.x / _scaleFactor
    readonly property real _geomY: root.geometry.y / _scaleFactor
    property real _geomZ: root.depth / (_scaleFactor * 2.0) + root.depth * root.explosionFactor

    QQ2.Behavior on _geomZ {
        QQ2.NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuart
        }
    }

    property real _highlightFactor : objectPicker.containsMouse ? 0.5 : 0.0;
    QQ2.Behavior on _highlightFactor {
        QQ2.NumberAnimation {
            duration: 100;
        }
    }

    Entity {
        id: widgetCube

        CuboidMesh {
            id: cubeMesh
            xExtent: root._geomWidth
            yExtent: root._geomHeight
            zExtent: 1
        }

        WidgetMaterial {
            id: material
            frontTextureImage: root.frontTextureImage
            backTextureImage: root.backTextureImage
            explosionFactor: root.explosionFactor
            highlightFactor: root._highlightFactor
            level: root.depth
        }

        Transform {
            id: transform
            translation: Qt.vector3d(
                            _geomWidth / 2.0 + _geomX - topLevelGeometry.width / 2.0 / _scaleFactor,
                            -_geomHeight / 2.0 - _geomY + topLevelGeometry.height / 2.0 / _scaleFactor,
                            _geomZ
                        )
        }

        ObjectPicker {
            id: objectPicker
            hoverEnabled: true
        }

        components: [ cubeMesh, material, transform, objectPicker ]
    }

    Entity {
        id: horizontals

        components: [
            GeometryRenderer {
                id: horizontalsMesh
                instanceCount: 1
                indexOffset: 0
                firstInstance: 0
                primitiveType: GeometryRenderer.Lines

                geometry: Geometry {
                    attributes: [
                        Attribute {
                            attributeType: Attribute.VertexAttribute
                            vertexBaseType: Attribute.Float
                            count: 4
                            vertexSize: 3
                            byteOffset: 0
                            byteStride: 3 * 4 // 3 vertices * sizeof(Float32)
                            name: defaultPositionAttributeName()
                            buffer: Buffer {
                                function generateVertexBufferData() {
                                    var v0 = Qt.vector2d(-_geomWidth / 2.0, _geomHeight / 2.0);
                                    var v1 = Qt.vector2d(-_geomWidth / 2.0, _geomHeight / 2.0);
                                    var v2 = Qt.vector2d(_geomWidth / 2.0, _geomHeight / 2.0);
                                    var v3 = Qt.vector2d(_geomWidth / 2.0, _geomHeight / 2.0);

                                    return new Float32Array([v0.x, v0.y, -0.5,
                                                             v1.x, v1.y, -0.5,
                                                             v2.x, v2.y, -0.5,
                                                             v3.x, v3.y, -0.5]);
                                }

                                type: Buffer.VertexBuffer
                                data: generateVertexBufferData()
                            }
                        }
                    ]
                }
            },

            Material {
                effect: Effect {
                    techniques: [
                        Technique {
                            graphicsApiFilter {
                                api: GraphicsApiFilter.OpenGL
                                profile: GraphicsApiFilter.CoreProfile
                                majorVersion: 3
                                minorVersion: 3
                            }

                            filterKeys: [
                                FilterKey {
                                      name: "renderingStyle"
                                      value: "forward"
                                }
                            ]

                            parameters: [
                                Parameter {
                                    name: "widget.explosionFactor"
                                    value: root.explosionFactor
                                },
                                Parameter {
                                    name: "widget.level"
                                    value: root.depth
                                }
                            ]

                            renderPasses: [
                                RenderPass {
                                    shaderProgram: ShaderProgram {
                                        vertexShaderCode: loadSource("qrc:/assets/shaders/horizontal.vert")
                                        geometryShaderCode: loadSource("qrc:/assets/shaders/horizontal.geom")
                                        fragmentShaderCode: loadSource("qrc:/assets/shaders/horizontal.frag")
                                    }
                                }
                            ]
                        }
                    ]
                }
            },

            Transform {
                translation: Qt.vector3d(
                                _geomWidth / 2.0 + _geomX - topLevelGeometry.width / 2.0 / _scaleFactor,
                                -_geomHeight / 2.0 - _geomY + topLevelGeometry.height / 2.0 / _scaleFactor,
                                _geomZ
                            )
            }
        ]
    }
}
