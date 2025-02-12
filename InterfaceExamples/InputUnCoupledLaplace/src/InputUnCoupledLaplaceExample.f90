!> \file
!> \author Chris Bradley
!> \brief This is an example program which solves a weakly coupled Laplace equation in two regions using OpenCMISS calls.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> \example InterfaceExamples/3DCoupledLaplace/src/3DCoupledLaplaceExample.f90
!! Example program which sets up a field in two regions using OpenCMISS calls.
!! \par Latest Builds:
!! \li <a href='http://autotest.bioeng.auckland.ac.nz/opencmiss-build/logs_x86_64-linux/InterfaceExamples/CoupledLaplace/build-intel'>Linux Intel Build</a>
!! \li <a href='http://autotest.bioeng.auckland.ac.nz/opencmiss-build/logs_x86_64-linux/InterfaceExamples/CoupledLaplace/build-gnu'>Linux GNU Build</a>
!<

!> Main program
PROGRAM THREEDCOUPLEDLAPLACE

  USE OPENCMISS
  USE FLUID_MECHANICS_IO_ROUTINES
  
#ifdef WIN32
  USE IFQWIN
#endif

  IMPLICIT NONE

  !Test program parameters

  INTEGER(CMISSIntg), PARAMETER :: CoordinateSystem1UserNumber=1
  INTEGER(CMISSIntg), PARAMETER :: CoordinateSystem2UserNumber=2
  INTEGER(CMISSIntg), PARAMETER :: Region1UserNumber=3
  INTEGER(CMISSIntg), PARAMETER :: Region2UserNumber=4
  INTEGER(CMISSIntg), PARAMETER :: Basis1UserNumber=5
  INTEGER(CMISSIntg), PARAMETER :: Basis2UserNumber=6
  INTEGER(CMISSIntg), PARAMETER :: InterfaceBasisUserNumber=7
  INTEGER(CMISSIntg), PARAMETER :: GeneratedMesh1UserNumber=8
  INTEGER(CMISSIntg), PARAMETER :: GeneratedMesh2UserNumber=9
  INTEGER(CMISSIntg), PARAMETER :: InterfaceGeneratedMeshUserNumber=10
  INTEGER(CMISSIntg), PARAMETER :: Mesh1UserNumber=11
  INTEGER(CMISSIntg), PARAMETER :: Mesh2UserNumber=12
  INTEGER(CMISSIntg), PARAMETER :: InterfaceMeshUserNumber=13
  INTEGER(CMISSIntg), PARAMETER :: Decomposition1UserNumber=14
  INTEGER(CMISSIntg), PARAMETER :: Decomposition2UserNumber=15
  INTEGER(CMISSIntg), PARAMETER :: InterfaceDecompositionUserNumber=16
  INTEGER(CMISSIntg), PARAMETER :: GeometricField1UserNumber=17
  INTEGER(CMISSIntg), PARAMETER :: GeometricField2UserNumber=18
  INTEGER(CMISSIntg), PARAMETER :: InterfaceGeometricFieldUserNumber=19
  INTEGER(CMISSIntg), PARAMETER :: EquationsSet1UserNumber=20
  INTEGER(CMISSIntg), PARAMETER :: EquationsSet2UserNumber=21
  INTEGER(CMISSIntg), PARAMETER :: DependentField1UserNumber=22
  INTEGER(CMISSIntg), PARAMETER :: DependentField2UserNumber=23
  INTEGER(CMISSIntg), PARAMETER :: InterfaceUserNumber=24
  INTEGER(CMISSIntg), PARAMETER :: InterfaceConditionUserNumber=25
  INTEGER(CMISSIntg), PARAMETER :: LagrangeFieldUserNumber=26
  INTEGER(CMISSIntg), PARAMETER :: CoupledProblemUserNumber=27
  INTEGER(CMISSIntg), PARAMETER :: InterfaceMappingBasisUserNumber=28
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetField1UserNumber=40
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetField2UserNumber=41
 
  !Program types

  TYPE(EXPORT_CONTAINER):: CM1,CM2,CM3
  TYPE(COUPLING_PARAMETERS):: CMX
  TYPE(BOUNDARY_PARAMETERS):: BC
  
  !Program variables
  INTEGER(CMISSIntg) :: NUMBER_GLOBAL_X_ELEMENTS,NUMBER_GLOBAL_Y_ELEMENTS,NUMBER_GLOBAL_Z_ELEMENTS, &
    & NUMBER_OF_NODE_XI !INTERPOLATION_TYPE,NUMBER_OF_GAUSS_XI
  INTEGER(CMISSIntg) :: EquationsSet1Index,EquationsSet2Index
  INTEGER(CMISSIntg) :: FirstNodeNumber,LastNodeNumber
  INTEGER(CMISSIntg) :: FirstNodeDomain,LastNodeDomain
  INTEGER(CMISSIntg) :: InterfaceConditionIndex
  INTEGER(CMISSIntg) :: Mesh1Index,Mesh2Index
  INTEGER(CMISSIntg) :: NumberOfComputationalNodes,ComputationalNodeNumber
  INTEGER(CMISSIntg) :: y_element_idx,z_element_idx,mesh_local_y_node,mesh_local_z_node,ic_idx
  REAL(CMISSDP) :: XI2(2),XI3(3),VALUE

  INTEGER(CMISSIntg) :: NUMBER_OF_DIMENSIONS1,NUMBER_OF_DIMENSIONS2,NUMBER_OF_DIMENSIONS_INTERFACE
  
  INTEGER(CMISSIntg) :: BASIS_TYPE1,BASIS_TYPE2,BASIS_TYPE_INTERFACE
  INTEGER(CMISSIntg) :: BASIS_NUMBER_SPACE1,BASIS_NUMBER_SPACE2,BASIS_NUMBER_SPACE_INTERFACE
!   INTEGER(CMISSIntg) :: BASIS_NUMBER_VELOCITY1,BASIS_NUMBER_VELOCITY2
!   INTEGER(CMISSIntg) :: BASIS_NUMBER_PRESSURE1,BASIS_NUMBER_PRESSURE2
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_SPACE1,BASIS_XI_GAUSS_SPACE2,BASIS_XI_GAUSS_INTERFACE
!   INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_VELOCITY1,BASIS_XI_GAUSS_VELOCITY2
!   INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_PRESSURE1,BASIS_XI_GAUSS_PRESSURE2
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_SPACE1,BASIS_XI_INTERPOLATION_SPACE2,BASIS_XI_INTERPOLATION_INTERFACE
!   INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_VELOCITY1,BASIS_XI_INTERPOLATION_VELOCITY2
!   INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_PRESSURE1,BASIS_XI_INTERPOLATION_PRESSURE2
  INTEGER(CMISSIntg) :: MESH_NUMBER_OF_COMPONENTS1,MESH_NUMBER_OF_COMPONENTS2,MESH_NUMBER_OF_COMPONENTS_INTERFACE
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_SPACE1,MESH_COMPONENT_NUMBER_SPACE2,MESH_COMPONENT_NUMBER_INTERFACE
!   INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_VELOCITY1,MESH_COMPONENT_NUMBER_VELOCITY2
!   INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_PRESSURE1,MESH_COMPONENT_NUMBER_PRESSURE2
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_SPACE1,NUMBER_OF_NODES_SPACE2,NUMBER_OF_NODES_INTERFACE
!   INTEGER(CMISSIntg) :: NUMBER_OF_NODES_VELOCITY1,NUMBER_OF_NODES_VELOCITY2
!   INTEGER(CMISSIntg) :: NUMBER_OF_NODES_PRESSURE1,NUMBER_OF_NODES_PRESSURE2
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_SPACE1,NUMBER_OF_ELEMENT_NODES_SPACE2,NUMBER_OF_ELEMENT_NODES_INTERFACE
!   INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_VELOCITY1,NUMBER_OF_ELEMENT_NODES_VELOCITY2
!   INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_PRESSURE1,NUMBER_OF_ELEMENT_NODES_PRESSURE2
  INTEGER(CMISSIntg) :: TOTAL_NUMBER_OF_NODES1,TOTAL_NUMBER_OF_NODES2,TOTAL_NUMBER_OF_NODES_INTERFACE
  INTEGER(CMISSIntg) :: TOTAL_NUMBER_OF_ELEMENTS1,TOTAL_NUMBER_OF_ELEMENTS2,TOTAL_NUMBER_OF_ELEMENTS_INTERFACE
  INTEGER(CMISSIntg) :: ELEMENT_NUMBER,COMPONENT_NUMBER,NODE_NUMBER

  !CMISS variables

  TYPE(CMISSBasisType) :: Basis1,Basis2,InterfaceBasis,InterfaceMappingBasis
  TYPE(CMISSBoundaryConditionsType) :: BoundaryConditions
  TYPE(CMISSCoordinateSystemType) :: CoordinateSystem1,CoordinateSystem2,WorldCoordinateSystem
  TYPE(CMISSDecompositionType) :: Decomposition1,Decomposition2,InterfaceDecomposition
  TYPE(CMISSEquationsType) :: Equations1,Equations2
  TYPE(CMISSEquationsSetType) :: EquationsSet1,EquationsSet2
  TYPE(CMISSFieldType) :: GeometricField1,GeometricField2,InterfaceGeometricField,DependentField1, &
    & DependentField2,LagrangeField,EquationsSetField1,EquationsSetField2
  TYPE(CMISSFieldsType) :: Fields1,Fields2,InterfaceFields
  TYPE(CMISSGeneratedMeshType) :: GeneratedMesh1,GeneratedMesh2,InterfaceGeneratedMesh
  TYPE(CMISSInterfaceType) :: Interface
  TYPE(CMISSInterfaceConditionType) :: InterfaceCondition
  TYPE(CMISSInterfaceEquationsType) :: InterfaceEquations
  TYPE(CMISSInterfaceMeshConnectivityType) :: InterfaceMeshConnectivity
  !Nodes
  TYPE(CMISSNodesType) :: Nodes1
  TYPE(CMISSNodesType) :: Nodes2
  TYPE(CMISSNodesType) :: InterfaceNodes
  !Elements
  TYPE(CMISSMeshElementsType) :: MeshElements1
  TYPE(CMISSMeshElementsType) :: MeshElements2
  TYPE(CMISSMeshElementsType) :: InterfaceMeshElements
  TYPE(CMISSMeshType) :: Mesh1,Mesh2,InterfaceMesh
  TYPE(CMISSNodesType) :: Nodes
  TYPE(CMISSProblemType) :: CoupledProblem
  TYPE(CMISSRegionType) :: Region1,Region2,WorldRegion
  TYPE(CMISSSolverType) :: CoupledSolver
  TYPE(CMISSSolverEquationsType) :: CoupledSolverEquations
  
#ifdef WIN32
  !Quickwin type
  LOGICAL :: QUICKWIN_STATUS=.FALSE.
  TYPE(WINDOWCONFIG) :: QUICKWIN_WINDOW_CONFIG
#endif
  
  !Generic CMISS variables
  
  INTEGER(CMISSIntg) :: Err
  
#ifdef WIN32
  !Initialise QuickWin
  QUICKWIN_WINDOW_CONFIG%TITLE="General Output" !Window title
  QUICKWIN_WINDOW_CONFIG%NUMTEXTROWS=-1 !Max possible number of rows
  QUICKWIN_WINDOW_CONFIG%MODE=QWIN$SCROLLDOWN
  !Set the window parameters
  QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
  !If attempt fails set with system estimated values
  IF(.NOT.QUICKWIN_STATUS) QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
#endif

  !
  !================================================================================================================================
  !

  !INITIALISE OPENCMISS


  !Intialise OpenCMISS
  CALL CMISSInitialise(WorldCoordinateSystem,WorldRegion,Err)

  !Set error handling mode
  CALL CMISSErrorHandlingModeSet(CMISSTrapError,Err)
 
  !Set diganostics for testing
  !CALL CMISSDiagnosticsSetOn(CMISSFromDiagType,[1,2,3,4,5],"Diagnostics",["SOLVER_MAPPING_CALCULATE         ", &
  !  & "SOLVER_MATRIX_STRUCTURE_CALCULATE"],Err)
  
  !
  !================================================================================================================================
  !

  !CHECK COMPUTATIONAL NODE

  !Get the computational nodes information
  CALL CMISSComputationalNumberOfNodesGet(NumberOfComputationalNodes,Err)
  CALL CMISSComputationalNodeNumberGet(ComputationalNodeNumber,Err)

  !
  !================================================================================================================================
  !

  !PROBLEM CONTROL PANEL

  !Import cmHeart mesh information
  CALL FLUID_MECHANICS_IO_READ_CMHEART(CM1,CM2,CM3,CMX,BC,Err)

  !Information for mesh 1
  BASIS_NUMBER_SPACE1=CM1%ID_M
!   BASIS_NUMBER_VELOCITY1=CM1%ID_V
!   BASIS_NUMBER_PRESSURE1=CM1%ID_P
  NUMBER_OF_DIMENSIONS1=CM1%D
  BASIS_TYPE1=CM1%IT_T
  BASIS_XI_INTERPOLATION_SPACE1=CM1%IT_M
!   BASIS_XI_INTERPOLATION_VELOCITY1=CM1%IT_V
!   BASIS_XI_INTERPOLATION_PRESSURE1=CM1%IT_P
  NUMBER_OF_NODES_SPACE1=CM1%N_M
!   NUMBER_OF_NODES_VELOCITY1=CM1%N_V
!   NUMBER_OF_NODES_PRESSURE1=CM1%N_P
  TOTAL_NUMBER_OF_NODES1=CM1%N_T
  TOTAL_NUMBER_OF_ELEMENTS1=CM1%E_T
  NUMBER_OF_ELEMENT_NODES_SPACE1=CM1%EN_M
!   NUMBER_OF_ELEMENT_NODES_VELOCITY1=CM1%EN_V
!   NUMBER_OF_ELEMENT_NODES_PRESSURE1=CM1%EN_P
  !Information for mesh 2
  BASIS_NUMBER_SPACE2=CM2%ID_M
!   BASIS_NUMBER_VELOCITY2=CM2%ID_V
!   BASIS_NUMBER_PRESSURE2=CM2%ID_P
  NUMBER_OF_DIMENSIONS2=CM2%D
  BASIS_TYPE2=CM2%IT_T
  BASIS_XI_INTERPOLATION_SPACE2=CM2%IT_M
!   BASIS_XI_INTERPOLATION_VELOCITY2=CM2%IT_V
!   BASIS_XI_INTERPOLATION_PRESSURE2=CM2%IT_P
  NUMBER_OF_NODES_SPACE2=CM2%N_M
!   NUMBER_OF_NODES_VELOCITY2=CM2%N_V
!   NUMBER_OF_NODES_PRESSURE2=CM2%N_P
  TOTAL_NUMBER_OF_NODES2=CM2%N_T
  TOTAL_NUMBER_OF_ELEMENTS2=CM2%E_T
  NUMBER_OF_ELEMENT_NODES_SPACE2=CM2%EN_M
!   NUMBER_OF_ELEMENT_NODES_VELOCITY2=CM2%EN_V
!   NUMBER_OF_ELEMENT_NODES_PRESSURE2=CM2%EN_P
  !Set interpolation parameters
  BASIS_XI_GAUSS_SPACE1=3
!   BASIS_XI_GAUSS_VELOCITY1=3
!   BASIS_XI_GAUSS_PRESSURE1=3
  BASIS_XI_GAUSS_SPACE2=3
!   BASIS_XI_GAUSS_VELOCITY2=3
!   BASIS_XI_GAUSS_PRESSURE2=3
  BASIS_NUMBER_SPACE_INTERFACE=CM3%ID_M
!   BASIS_NUMBER_VELOCITY2=CM2%ID_V
!   BASIS_NUMBER_PRESSURE2=CM2%ID_P
  NUMBER_OF_DIMENSIONS_INTERFACE=CM3%D
  BASIS_TYPE_INTERFACE=CM3%IT_T
  BASIS_XI_INTERPOLATION_INTERFACE=CM3%IT_M
!   BASIS_XI_INTERPOLATION_VELOCITY2=CM2%IT_V
!   BASIS_XI_INTERPOLATION_PRESSURE2=CM2%IT_P
  NUMBER_OF_NODES_INTERFACE=CM3%N_M
!   NUMBER_OF_NODES_VELOCITY2=CM2%N_V
!   NUMBER_OF_NODES_PRESSURE2=CM2%N_P
  TOTAL_NUMBER_OF_NODES_INTERFACE=CM3%N_T
  TOTAL_NUMBER_OF_ELEMENTS_INTERFACE=CM3%E_T
  NUMBER_OF_ELEMENT_NODES_INTERFACE=CM3%EN_M
!   NUMBER_OF_ELEMENT_NODES_VELOCITY2=CM2%EN_V
!   NUMBER_OF_ELEMENT_NODES_PRESSURE2=CM2%EN_P
  !Set interpolation parameters
  BASIS_XI_GAUSS_INTERFACE=3
!   BASIS_XI_GAUSS_VELOCITY1=3
!   BASIS_XI_GAUSS_PRESSURE1=3
  BASIS_XI_GAUSS_INTERFACE=3
!   BASIS_XI_GAUSS_VELOCITY2=3
!   BASIS_XI_GAUSS_PRESSURE2=3


  !
  !================================================================================================================================
  !

  !COORDINATE SYSTEM

  
  !Start the creation of a new RC coordinate system for the first region
  PRINT *, ' == >> CREATING COORDINATE SYSTEM(1) << == '
  CALL CMISSCoordinateSystemTypeInitialise(CoordinateSystem1,Err)
  CALL CMISSCoordinateSystemCreateStart(CoordinateSystem1UserNumber,CoordinateSystem1,Err)
  !Set the coordinate system dimension
  CALL CMISSCoordinateSystemDimensionSet(CoordinateSystem1,NUMBER_OF_DIMENSIONS1,Err)
  !Finish the creation of the coordinate system
  CALL CMISSCoordinateSystemCreateFinish(CoordinateSystem1,Err)

  !Start the creation of a new RC coordinate system for the second region
  PRINT *, ' == >> CREATING COORDINATE SYSTEM(2) << == '
  CALL CMISSCoordinateSystemTypeInitialise(CoordinateSystem2,Err)
  CALL CMISSCoordinateSystemCreateStart(CoordinateSystem2UserNumber,CoordinateSystem2,Err)
  !Set the coordinate system dimension
  CALL CMISSCoordinateSystemDimensionSet(CoordinateSystem2,NUMBER_OF_DIMENSIONS2,Err)
  !Finish the creation of the coordinate system
  CALL CMISSCoordinateSystemCreateFinish(CoordinateSystem2,Err)

  !
  !================================================================================================================================
  !

  !REGION
  
  !Start the creation of the first region
  PRINT *, ' == >> CREATING REGION(1) << == '
  CALL CMISSRegionTypeInitialise(Region1,Err)
  CALL CMISSRegionCreateStart(Region1UserNumber,WorldRegion,Region1,Err)
  CALL CMISSRegionLabelSet(Region1,"Region1",Err)
  !Set the regions coordinate system as defined above
  CALL CMISSRegionCoordinateSystemSet(Region1,CoordinateSystem1,Err)
  !Finish the creation of the region
  CALL CMISSRegionCreateFinish(Region1,Err)

  !Start the creation of the second region
  PRINT *, ' == >> CREATING REGION(2) << == '
  CALL CMISSRegionTypeInitialise(Region2,Err)
  CALL CMISSRegionCreateStart(Region2UserNumber,WorldRegion,Region2,Err)
  CALL CMISSRegionLabelSet(Region2,"Region2",Err)
  !Set the regions coordinate system as defined above
  CALL CMISSRegionCoordinateSystemSet(Region2,CoordinateSystem2,Err)
  !Finish the creation of the region
  CALL CMISSRegionCreateFinish(Region2,Err)

  !
  !================================================================================================================================
  !

  !BASES


  !Start the creation of a bI/tri-linear-Lagrange basis
  PRINT *, ' == >> CREATING BASIS(1) << == '
  CALL CMISSBasisTypeInitialise(Basis1,Err)
  CALL CMISSBasisCreateStart(Basis1UserNumber,Basis1,Err)
  !Set the basis type (Lagrange/Simplex)
  CALL CMISSBasisTypeSet(Basis1,BASIS_TYPE1,Err)
  !Set the basis xi number
  CALL CMISSBasisNumberOfXiSet(Basis1,NUMBER_OF_DIMENSIONS1,Err)
  !Set the basis xi interpolation and number of Gauss points
  IF(NUMBER_OF_DIMENSIONS1==2.AND.NUMBER_OF_DIMENSIONS2==2) THEN
    CALL CMISSBasisInterpolationXiSet(Basis1,(/BASIS_XI_INTERPOLATION_SPACE1,BASIS_XI_INTERPOLATION_SPACE1/),Err)
    IF(BASIS_TYPE1/=CMISSBasisSimplexType) THEN
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(Basis1,(/BASIS_XI_GAUSS_SPACE1,BASIS_XI_GAUSS_SPACE1/),Err)
    ELSE
      CALL CMISSBasisQuadratureOrderSet(Basis1,BASIS_XI_GAUSS_SPACE1+1,Err)
    ENDIF
  ELSE IF(NUMBER_OF_DIMENSIONS1==3.AND.NUMBER_OF_DIMENSIONS2==3) THEN
    CALL CMISSBasisInterpolationXiSet(Basis1,(/BASIS_XI_INTERPOLATION_SPACE1,BASIS_XI_INTERPOLATION_SPACE1, & 
      & BASIS_XI_INTERPOLATION_SPACE1/),Err)                         
    IF(BASIS_TYPE1/=CMISSBasisSimplexType) THEN
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(Basis1,(/BASIS_XI_GAUSS_SPACE1,BASIS_XI_GAUSS_SPACE1,BASIS_XI_GAUSS_SPACE1/), & 
        & Err)
    ELSE
      CALL CMISSBasisQuadratureOrderSet(Basis1,BASIS_XI_GAUSS_SPACE1+1,Err)
    ENDIF
  ELSE
    CALL HANDLE_ERROR("Dimension coupling error.")
  ENDIF
  !Finish the creation of the basis
  CALL CMISSBasisCreateFinish(Basis1,Err)

  !Start the creation of a bI/tri-XXX-Lagrange basis
  PRINT *, ' == >> CREATING BASIS(2) << == '
  CALL CMISSBasisTypeInitialise(Basis2,Err)
  CALL CMISSBasisCreateStart(Basis2UserNumber,Basis2,Err)
  !Set the basis type (Lagrange/Simplex)
  CALL CMISSBasisTypeSet(Basis2,BASIS_TYPE2,Err)
  !Set the basis xi number
  CALL CMISSBasisNumberOfXiSet(Basis2,NUMBER_OF_DIMENSIONS2,Err)
  !Set the basis xi interpolation and number of Gauss points
  IF(NUMBER_OF_DIMENSIONS1==2.AND.NUMBER_OF_DIMENSIONS2==2) THEN
    CALL CMISSBasisInterpolationXiSet(Basis2,(/BASIS_XI_INTERPOLATION_SPACE2,BASIS_XI_INTERPOLATION_SPACE2/),Err)
    IF(BASIS_TYPE2/=CMISSBasisSimplexType) THEN
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(Basis2,(/BASIS_XI_GAUSS_SPACE2,BASIS_XI_GAUSS_SPACE2/),Err)
    ELSE
      CALL CMISSBasisQuadratureOrderSet(Basis2,BASIS_XI_GAUSS_SPACE2+1,Err)
    ENDIF
  ELSE IF(NUMBER_OF_DIMENSIONS1==3.AND.NUMBER_OF_DIMENSIONS2==3) THEN
    CALL CMISSBasisInterpolationXiSet(Basis2,(/BASIS_XI_INTERPOLATION_SPACE2,BASIS_XI_INTERPOLATION_SPACE2, & 
      & BASIS_XI_INTERPOLATION_SPACE2/),Err)                         
    IF(BASIS_TYPE2/=CMISSBasisSimplexType) THEN
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(Basis2,(/BASIS_XI_GAUSS_SPACE2,BASIS_XI_GAUSS_SPACE2,BASIS_XI_GAUSS_SPACE2/), & 
        & Err)
    ELSE
      CALL CMISSBasisQuadratureOrderSet(Basis2,BASIS_XI_GAUSS_SPACE2+1,Err)
    ENDIF
  ELSE
    CALL HANDLE_ERROR("Dimension coupling error.")
  ENDIF
  !Finish the creation of the basis
  CALL CMISSBasisCreateFinish(Basis2,Err)


  !
  !================================================================================================================================
  !

  !MESH

  
  !Start the creation of a generated mesh in the first region
  PRINT *, ' == >> CREATING MESH(1) FROM INPUT DATA << == '
  !Start the creation of mesh nodes
  CALL CMISSNodesTypeInitialise(Nodes1,Err)
  CALL CMISSMeshTypeInitialise(Mesh1,Err)
  CALL CMISSNodesCreateStart(Region1,TOTAL_NUMBER_OF_NODES1,Nodes1,Err)
  CALL CMISSNodesCreateFinish(Nodes1,Err)
  !Start the creation of the mesh
  CALL CMISSMeshCreateStart(Mesh1UserNumber,Region1,NUMBER_OF_DIMENSIONS1,Mesh1,Err)
  !Set number of mesh elements
  CALL CMISSMeshNumberOfElementsSet(Mesh1,TOTAL_NUMBER_OF_ELEMENTS1,Err)
  !Set number of mesh components
  MESH_NUMBER_OF_COMPONENTS1=1
  CALL CMISSMeshNumberOfComponentsSet(Mesh1,MESH_NUMBER_OF_COMPONENTS1,Err)
  !Specify spatial mesh component
  CALL CMISSMeshElementsTypeInitialise(MeshElements1,Err)
  MESH_COMPONENT_NUMBER_SPACE1=1
  CALL CMISSMeshElementsCreateStart(Mesh1,MESH_COMPONENT_NUMBER_SPACE1,Basis1,MeshElements1,Err)
  DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS1
    CALL CMISSMeshElementsNodesSet(MeshElements1,ELEMENT_NUMBER,CM1%M(ELEMENT_NUMBER,1:NUMBER_OF_ELEMENT_NODES_SPACE1),Err)
  ENDDO
  CALL CMISSMeshElementsCreateFinish(MeshElements1,Err)
  !Finish the creation of the mesh
  CALL CMISSMeshCreateFinish(Mesh1,Err)



  !Start the creation of a generated mesh in the second region
  PRINT *, ' == >> CREATING MESH(2) FROM INPUT DATA << == '
  !Start the creation of mesh nodes
  CALL CMISSNodesTypeInitialise(Nodes2,Err)
  CALL CMISSMeshTypeInitialise(Mesh2,Err)
  CALL CMISSNodesCreateStart(Region2,TOTAL_NUMBER_OF_NODES2,Nodes2,Err)
  CALL CMISSNodesCreateFinish(Nodes2,Err)
  !Start the creation of the mesh
  CALL CMISSMeshCreateStart(Mesh2UserNumber,Region2,NUMBER_OF_DIMENSIONS2,Mesh2,Err)
  !Set number of mesh elements
  CALL CMISSMeshNumberOfElementsSet(Mesh2,TOTAL_NUMBER_OF_ELEMENTS2,Err)
  MESH_NUMBER_OF_COMPONENTS2=1
  !Set number of mesh components
  CALL CMISSMeshNumberOfComponentsSet(Mesh2,MESH_NUMBER_OF_COMPONENTS2,Err)
  !Specify spatial mesh component
  CALL CMISSMeshElementsTypeInitialise(MeshElements2,Err)
  MESH_COMPONENT_NUMBER_SPACE2=1
  CALL CMISSMeshElementsCreateStart(Mesh2,MESH_COMPONENT_NUMBER_SPACE2,Basis2,MeshElements2,Err)
  DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS2
    CALL CMISSMeshElementsNodesSet(MeshElements2,ELEMENT_NUMBER,CM2%M(ELEMENT_NUMBER,1:NUMBER_OF_ELEMENT_NODES_SPACE2),Err)
  ENDDO
  CALL CMISSMeshElementsCreateFinish(MeshElements2,Err)
  !Finish the creation of the mesh
  CALL CMISSMeshCreateFinish(Mesh2,Err)

  !
  !================================================================================================================================
  !

  !INTERFACE DEFINITION

  !Create an interface between the two meshes
  PRINT *, ' == >> CREATING INTERFACE << == '
  CALL CMISSInterfaceTypeInitialise(Interface,Err)
  CALL CMISSInterfaceCreateStart(InterfaceUserNumber,WorldRegion,Interface,Err)
  CALL CMISSInterfaceLabelSet(Interface,"Interface",Err)
  !Add in the two meshes
  CALL CMISSInterfaceMeshAdd(Interface,Mesh1,Mesh1Index,Err)
  CALL CMISSInterfaceMeshAdd(Interface,Mesh2,Mesh2Index,Err)
  !Finish creating the interface
  CALL CMISSInterfaceCreateFinish(Interface,Err)

  !Start the creation of a (bi)-linear-Lagrange basis
  PRINT *, ' == >> CREATING INTERFACE BASIS << == '
  CALL CMISSBasisTypeInitialise(InterfaceBasis,Err)
  CALL CMISSBasisCreateStart(InterfaceBasisUserNumber,InterfaceBasis,Err)
  CALL CMISSBasisTypeSet(InterfaceBasis,BASIS_TYPE_INTERFACE,Err)
  CALL CMISSBasisNumberOfXiSet(InterfaceBasis,NUMBER_OF_DIMENSIONS_INTERFACE,Err)
  !Set the basis xi interpolation and number of Gauss points
  IF(NUMBER_OF_DIMENSIONS1==3.AND.NUMBER_OF_DIMENSIONS2==3.AND.NUMBER_OF_DIMENSIONS_INTERFACE==2) THEN
    CALL CMISSBasisInterpolationXiSet(InterfaceBasis,(/BASIS_XI_INTERPOLATION_INTERFACE,BASIS_XI_INTERPOLATION_INTERFACE/),Err)

! ! ! TEST TEST TEST

! ! !     CALL CMISSBasisInterpolationXiSet(InterfaceBasis,[CMISSBasisLinearLagrangeInterpolation, &
! ! !       & CMISSBasisLinearLagrangeInterpolation],Err)


    IF(BASIS_TYPE_INTERFACE/=CMISSBasisSimplexType) THEN
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(InterfaceBasis,(/BASIS_XI_GAUSS_INTERFACE,BASIS_XI_GAUSS_INTERFACE/),Err)
    ELSE
      CALL CMISSBasisQuadratureOrderSet(InterfaceBasis,BASIS_XI_GAUSS_INTERFACE+1,Err)
    ENDIF
  ENDIF



  !Finish the creation of the basis
  CALL CMISSBasisCreateFinish(InterfaceBasis,Err)


  !
  !================================================================================================================================
  !

  !INTERFACE MAPPING

  !Start the creation of a (bi)-linear-Lagrange basis
  PRINT *, ' == >> CREATING INTERFACE MAPPING BASIS << == '
  CALL CMISSBasisTypeInitialise(InterfaceMappingBasis,Err)
  CALL CMISSBasisCreateStart(InterfaceMappingBasisUserNumber,InterfaceMappingBasis,Err)
  CALL CMISSBasisTypeSet(InterfaceMappingBasis,BASIS_TYPE_INTERFACE,Err)
  CALL CMISSBasisNumberOfXiSet(InterfaceMappingBasis,NUMBER_OF_DIMENSIONS_INTERFACE,Err)
  IF(NUMBER_OF_DIMENSIONS1==3.AND.NUMBER_OF_DIMENSIONS2==3.AND.NUMBER_OF_DIMENSIONS_INTERFACE==2) THEN
    CALL CMISSBasisInterpolationXiSet(InterfaceMappingBasis,(/BASIS_XI_INTERPOLATION_INTERFACE, &
      & BASIS_XI_INTERPOLATION_INTERFACE/),Err)

! ! ! TEST TEST TEST

! ! !     CALL CMISSBasisInterpolationXiSet(InterfaceMappingBasis,[CMISSBasisLinearLagrangeInterpolation, &
! ! !       & CMISSBasisLinearLagrangeInterpolation],Err)


    IF(BASIS_TYPE_INTERFACE/=CMISSBasisSimplexType) THEN
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(InterfaceMappingBasis,(/BASIS_XI_GAUSS_INTERFACE,BASIS_XI_GAUSS_INTERFACE/),Err)
    ELSE
      CALL CMISSBasisQuadratureOrderSet(InterfaceMappingBasis,BASIS_XI_GAUSS_INTERFACE+1,Err)
    ENDIF
  ENDIF
  !Finish the creation of the basis
  CALL CMISSBasisCreateFinish(InterfaceMappingBasis,Err)

  !
  !================================================================================================================================
  !

  !INTERFACE MESH
  
  !Start the creation of a generated mesh for the interface
  PRINT *, ' == >> CREATING INTERFACE MESH FROM INPUT DATA << == '
  !Start the creation of mesh nodes
  CALL CMISSNodesTypeInitialise(InterfaceNodes,Err)
  CALL CMISSMeshTypeInitialise(InterfaceMesh,Err)
  CALL CMISSNodesCreateStart(Interface,TOTAL_NUMBER_OF_NODES_INTERFACE,InterfaceNodes,Err)
  CALL CMISSNodesCreateFinish(InterfaceNodes,Err)
  !Start the creation of the mesh
  CALL CMISSMeshCreateStart(InterfaceMeshUserNumber,Interface,NUMBER_OF_DIMENSIONS_INTERFACE,InterfaceMesh,Err)
  !Set number of mesh elements
  CALL CMISSMeshNumberOfElementsSet(InterfaceMesh,TOTAL_NUMBER_OF_ELEMENTS_INTERFACE,Err)
  MESH_NUMBER_OF_COMPONENTS_INTERFACE=1
  !Set number of mesh components
  CALL CMISSMeshNumberOfComponentsSet(InterfaceMesh,MESH_NUMBER_OF_COMPONENTS_INTERFACE,Err)
  !Specify spatial mesh component
  CALL CMISSMeshElementsTypeInitialise(InterfaceMeshElements,Err)
  MESH_COMPONENT_NUMBER_INTERFACE=1
  CALL CMISSMeshElementsCreateStart(InterfaceMesh,MESH_COMPONENT_NUMBER_INTERFACE,InterfaceBasis,InterfaceMeshElements,Err)
  DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS_INTERFACE
    CALL CMISSMeshElementsNodesSet(InterfaceMeshElements,ELEMENT_NUMBER,CM3%M(ELEMENT_NUMBER, &
      & 1:NUMBER_OF_ELEMENT_NODES_INTERFACE),Err)
  ENDDO
  CALL CMISSMeshElementsCreateFinish(InterfaceMeshElements,Err)
  !Finish the creation of the mesh
  CALL CMISSMeshCreateFinish(InterfaceMesh,Err)


  !
  !================================================================================================================================
  !

  !INTERFACE CONNECTIVITY

  !Couple the interface meshes
  PRINT *, ' == >> CREATING INTERFACE MESHES CONNECTIVITY << == '
  CALL CMISSInterfaceMeshConnectivityTypeInitialise(InterfaceMeshConnectivity,Err)
  CALL CMISSInterfaceMeshConnectivityCreateStart(Interface,InterfaceMesh,InterfaceMeshConnectivity,Err)
  CALL CMISSInterfaceMeshConnectivitySetBasis(InterfaceMeshConnectivity,InterfaceMappingBasis,Err)

  DO ic_idx=1,CMX%NUMBER_OF_COUPLINGS
    !Map the interface element to the elements in mesh 1
    CALL CMISSInterfaceMeshConnectivityElementNumberSet(InterfaceMeshConnectivity,CMX%INTERFACE_ELEMENT_NUMBER(ic_idx), &
      & CMX%MESH1_ID,CMX%MESH1_ELEMENT_NUMBER(ic_idx),Err)
    !Map the interface element to the elements in mesh 2
    CALL CMISSInterfaceMeshConnectivityElementNumberSet(InterfaceMeshConnectivity,CMX%INTERFACE_ELEMENT_NUMBER(ic_idx), &
      & CMX%MESH2_ID,CMX%MESH2_ELEMENT_NUMBER(ic_idx),Err)
  ENDDO !ic_idx

  DO ic_idx=1,CMX%NUMBER_OF_COUPLINGS
    !Define xi mapping in mesh 1
    CALL CMISSInterfaceMeshConnectivityElementXiSet(InterfaceMeshConnectivity,CMX%INTERFACE_ELEMENT_NUMBER(ic_idx), & 
      & CMX%MESH1_ID,CMX%MESH1_ELEMENT_NUMBER(ic_idx),CMX%INTERFACE_ELEMENT_LOCAL_NODE(ic_idx),1, &
      & CMX%MESH1_ELEMENT_XI(ic_idx,1:3),Err)
    !Define xi mapping in mesh 2
    CALL CMISSInterfaceMeshConnectivityElementXiSet(InterfaceMeshConnectivity,CMX%INTERFACE_ELEMENT_NUMBER(ic_idx), & 
      & CMX%MESH2_ID,CMX%MESH2_ELEMENT_NUMBER(ic_idx),CMX%INTERFACE_ELEMENT_LOCAL_NODE(ic_idx),1, &
      & CMX%MESH2_ELEMENT_XI(ic_idx,1:3),Err)
  ENDDO !ic_idx


  CALL CMISSInterfaceMeshConnectivityCreateFinish(InterfaceMeshConnectivity,Err)


  !
  !================================================================================================================================
  !

  !GEOMETRIC FIELD & DECOMPOSITION

  !Create a decomposition for mesh1
  PRINT *, ' == >> CREATING MESH(1) DECOMPOSITION << == '
  CALL CMISSDecompositionTypeInitialise(Decomposition1,Err)
  CALL CMISSDecompositionCreateStart(Decomposition1UserNumber,Mesh1,Decomposition1,Err)
  !Set the decomposition to be a general decomposition with the specified number of domains
  CALL CMISSDecompositionTypeSet(Decomposition1,CMISSDecompositionCalculatedType,Err)
  CALL CMISSDecompositionNumberOfDomainsSet(Decomposition1,NumberOfComputationalNodes,Err)
  !Finish the decomposition
  CALL CMISSDecompositionCreateFinish(Decomposition1,Err)

  !Create a decomposition for mesh2
  PRINT *, ' == >> CREATING MESH(2) DECOMPOSITION << == '
  CALL CMISSDecompositionTypeInitialise(Decomposition2,Err)
  CALL CMISSDecompositionCreateStart(Decomposition2UserNumber,Mesh2,Decomposition2,Err)
  !Set the decomposition to be a general decomposition with the specified number of domains
  CALL CMISSDecompositionTypeSet(Decomposition2,CMISSDecompositionCalculatedType,Err)
  CALL CMISSDecompositionNumberOfDomainsSet(Decomposition2,NumberOfComputationalNodes,Err)
  !Finish the decomposition
  CALL CMISSDecompositionCreateFinish(Decomposition2,Err)
  
  !Create a decomposition for the interface mesh
  PRINT *, ' == >> CREATING INTERFACE DECOMPOSITION << == '
  CALL CMISSDecompositionTypeInitialise(InterfaceDecomposition,Err)
  CALL CMISSDecompositionCreateStart(InterfaceDecompositionUserNumber,InterfaceMesh,InterfaceDecomposition,Err)
  !Set the decomposition to be a general decomposition with the specified number of domains
  CALL CMISSDecompositionTypeSet(InterfaceDecomposition,CMISSDecompositionCalculatedType,Err)
  CALL CMISSDecompositionNumberOfDomainsSet(InterfaceDecomposition,NumberOfComputationalNodes,Err)
  !Finish the decomposition
  CALL CMISSDecompositionCreateFinish(InterfaceDecomposition,Err)

  !Start to create a default (geometric) field on the first region
  PRINT *, ' == >> CREATING MESH(1) GEOMETRIC FIELD << == '
  CALL CMISSFieldTypeInitialise(GeometricField1,Err)
  CALL CMISSFieldCreateStart(GeometricField1UserNumber,Region1,GeometricField1,Err)
  !Set the decomposition to use
  CALL CMISSFieldMeshDecompositionSet(GeometricField1,Decomposition1,Err)
  !Set the domain to be used by the field components.
  CALL CMISSFieldComponentMeshComponentSet(GeometricField1,CMISSFieldUVariableType,1,1,Err)
  CALL CMISSFieldComponentMeshComponentSet(GeometricField1,CMISSFieldUVariableType,2,1,Err)
  IF(NUMBER_GLOBAL_Z_ELEMENTS/=0) THEN
    CALL CMISSFieldComponentMeshComponentSet(GeometricField1,CMISSFieldUVariableType,3,1,Err)
  ENDIF
  !Finish creating the first field
  CALL CMISSFieldCreateFinish(GeometricField1,Err)

  !Start to create a default (geometric) field on the second region
  PRINT *, ' == >> CREATING MESH(2) GEOMETRIC FIELD << == '
  CALL CMISSFieldTypeInitialise(GeometricField2,Err)
  CALL CMISSFieldCreateStart(GeometricField2UserNumber,Region2,GeometricField2,Err)
  !Set the decomposition to use
  CALL CMISSFieldMeshDecompositionSet(GeometricField2,Decomposition2,Err)
  !Set the domain to be used by the field components.
  CALL CMISSFieldComponentMeshComponentSet(GeometricField2,CMISSFieldUVariableType,1,1,Err)
  CALL CMISSFieldComponentMeshComponentSet(GeometricField2,CMISSFieldUVariableType,2,1,Err)
  IF(NUMBER_OF_DIMENSIONS1==3.AND.NUMBER_OF_DIMENSIONS2==3) THEN
    CALL CMISSFieldComponentMeshComponentSet(GeometricField2,CMISSFieldUVariableType,3,1,Err)
  ENDIF
  !Finish creating the second field
  CALL CMISSFieldCreateFinish(GeometricField2,Err)

  !Update the geometric field parameters for the first field
  DO NODE_NUMBER=1,NUMBER_OF_NODES_SPACE1
    DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS1
      VALUE=CM1%N(NODE_NUMBER,COMPONENT_NUMBER)
      CALL CMISSFieldParameterSetUpdateNode(GeometricField1,CMISSFieldUVariableType,CMISSFieldValuesSetType,1, & 
        & CMISSNoGlobalDerivative,NODE_NUMBER,COMPONENT_NUMBER,VALUE,Err)
    ENDDO
  ENDDO
  CALL CMISSFieldParameterSetUpdateStart(GeometricField1,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)
  CALL CMISSFieldParameterSetUpdateFinish(GeometricField1,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)

  !Update the geometric field parameters for the second field
  DO NODE_NUMBER=1,NUMBER_OF_NODES_SPACE2
    DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS2
      VALUE=CM2%N(NODE_NUMBER,COMPONENT_NUMBER)
      CALL CMISSFieldParameterSetUpdateNode(GeometricField2,CMISSFieldUVariableType,CMISSFieldValuesSetType,1, & 
        & CMISSNoGlobalDerivative,NODE_NUMBER,COMPONENT_NUMBER,VALUE,Err)
    ENDDO
  ENDDO
  CALL CMISSFieldParameterSetUpdateStart(GeometricField2,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)
  CALL CMISSFieldParameterSetUpdateFinish(GeometricField2,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)


  !
  !================================================================================================================================
  !

  !EQUATIONS SETS

   !Create the equations set for the first region
  PRINT *, ' == >> CREATING EQUATION SET(1) << == '
  CALL CMISSFieldTypeInitialise(EquationsSetField1,Err)
  CALL CMISSEquationsSetTypeInitialise(EquationsSet1,Err)
  CALL CMISSEquationsSetCreateStart(EquationsSet1UserNumber,Region1,GeometricField1,CMISSEquationsSetClassicalFieldClass, &
    & CMISSEquationsSetLaplaceEquationType,CMISSEquationsSetStandardLaplaceSubtype,EquationsSetField1UserNumber,&
    & EquationsSetField1,EquationsSet1,Err)
  !Set the equations set to be a standard Laplace problem
  !Finish creating the equations set
  CALL CMISSEquationsSetCreateFinish(EquationsSet1,Err)

  !Create the equations set for the second region
  PRINT *, ' == >> CREATING EQUATION SET(2) << == '
  CALL CMISSFieldTypeInitialise(EquationsSetField2,Err)
  CALL CMISSEquationsSetTypeInitialise(EquationsSet2,Err)
  CALL CMISSEquationsSetCreateStart(EquationsSet2UserNumber,Region2,GeometricField2,CMISSEquationsSetClassicalFieldClass, &
    & CMISSEquationsSetLaplaceEquationType,CMISSEquationsSetStandardLaplaceSubtype,EquationsSetField2UserNumber,&
    & EquationsSetField2,EquationsSet2,Err)
  !Finish creating the equations set
  CALL CMISSEquationsSetCreateFinish(EquationsSet2,Err)

  !
  !================================================================================================================================
  !

  !DEPENDENT FIELDS

  !Create the equations set dependent field variables for the first equations set
  PRINT *, ' == >> CREATING DEPENDENT FIELD(1) << == '
  CALL CMISSFieldTypeInitialise(DependentField1,Err)
  CALL CMISSEquationsSetDependentCreateStart(EquationsSet1,DependentField1UserNumber,DependentField1,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetDependentCreateFinish(EquationsSet1,Err)

  !Create the equations set dependent field variables for the second equations set
  PRINT *, ' == >> CREATING DEPENDENT FIELD(2) << == '
  CALL CMISSFieldTypeInitialise(DependentField2,Err)
  CALL CMISSEquationsSetDependentCreateStart(EquationsSet2,DependentField2UserNumber,DependentField2,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetDependentCreateFinish(EquationsSet2,Err)


  !
  !================================================================================================================================
  !

  !EQUATIONS

  !Create the equations set equations for the first equations set
  PRINT *, ' == >> CREATING EQUATIONS(1) << == '
  CALL CMISSEquationsTypeInitialise(Equations1,Err)
  CALL CMISSEquationsSetEquationsCreateStart(EquationsSet1,Equations1,Err)
  !Set the equations matrices sparsity type
  CALL CMISSEquationsSparsityTypeSet(Equations1,CMISSEquationsSparseMatrices,Err)
  !Set the equations set output
  !CALL CMISSEquationsOutputTypeSet(Equations1,CMISSEquationsNoOutput,Err)
  !CALL CMISSEquationsOutputTypeSet(Equations1,CMISSEquationsTimingOutput,Err)
  CALL CMISSEquationsOutputTypeSet(Equations1,CMISSEquationsMatrixOutput,Err)
  !CALL CMISSEquationsOutputTypeSet(Equations1,CMISSEquationsElementMatrixOutput,Err)
  !Finish the equations set equations
  CALL CMISSEquationsSetEquationsCreateFinish(EquationsSet1,Err)

  !Create the equations set equations for the second equations set
  PRINT *, ' == >> CREATING EQUATIONS(2) << == '
  CALL CMISSEquationsTypeInitialise(Equations2,Err)
  CALL CMISSEquationsSetEquationsCreateStart(EquationsSet2,Equations2,Err)
  !Set the equations matrices sparsity type
  CALL CMISSEquationsSparsityTypeSet(Equations2,CMISSEquationsSparseMatrices,Err)
  !Set the equations set output
  !CALL CMISSEquationsOutputTypeSet(Equations2,CMISSEquationsNoOutput,Err)
  CALL CMISSEquationsOutputTypeSet(Equations2,CMISSEquationsTimingOutput,Err)
  !CALL CMISSEquationsOutputTypeSet(Equations2,CMISSEquationsMatrixOutput,Err)
  !CALL CMISSEquationsOutputTypeSet(Equations2,CMISSEquationsElementMatrixOutput,Err)
  !Finish the equations set equations
  CALL CMISSEquationsSetEquationsCreateFinish(EquationsSet2,Err)


  !
  !================================================================================================================================
  !


  !INTERFACE GEOMETRIC FIELD

  !Start to create a default (geometric) field on the Interface
  PRINT *, ' == >> CREATING INTERFACE GEOMETRIC FIELD << == '
  CALL CMISSFieldTypeInitialise(InterfaceGeometricField,Err)
  CALL CMISSFieldCreateStart(InterfaceGeometricFieldUserNumber,Interface,InterfaceGeometricField,Err)
  !Set the decomposition to use
  CALL CMISSFieldMeshDecompositionSet(InterfaceGeometricField,InterfaceDecomposition,Err)
  !Set the domain to be used by the field components.
  CALL CMISSFieldComponentMeshComponentSet(InterfaceGeometricField,CMISSFieldUVariableType,1,1,Err)
  CALL CMISSFieldComponentMeshComponentSet(InterfaceGeometricField,CMISSFieldUVariableType,2,1,Err)
  IF(NUMBER_GLOBAL_Z_ELEMENTS/=0) THEN
    CALL CMISSFieldComponentMeshComponentSet(InterfaceGeometricField,CMISSFieldUVariableType,3,1,Err)
  ENDIF
  !Finish creating the first field
  CALL CMISSFieldCreateFinish(InterfaceGeometricField,Err)

 !Update the geometric field parameters for the interface field
  DO NODE_NUMBER=1,NUMBER_OF_NODES_INTERFACE
    DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS_INTERFACE+1
      VALUE=CM3%N(NODE_NUMBER,COMPONENT_NUMBER)
      CALL CMISSFieldParameterSetUpdateNode(InterfaceGeometricField,CMISSFieldUVariableType,CMISSFieldValuesSetType,1, & 
        & CMISSNoGlobalDerivative,NODE_NUMBER,COMPONENT_NUMBER,VALUE,Err)
    ENDDO
  ENDDO
  CALL CMISSFieldParameterSetUpdateStart(InterfaceGeometricField,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)
  CALL CMISSFieldParameterSetUpdateFinish(InterfaceGeometricField,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)

  !Create an interface condition between the two meshes
  PRINT *, ' == >> CREATING INTERFACE CONDITIONS << == '
  CALL CMISSInterfaceConditionTypeInitialise(InterfaceCondition,Err)
  CALL CMISSInterfaceConditionCreateStart(InterfaceConditionUserNumber,Interface,InterfaceGeometricField, &
    & InterfaceCondition,Err)
  !Specify the method for the interface condition
  CALL CMISSInterfaceConditionMethodSet(InterfaceCondition,CMISSInterfaceConditionLagrangeMultipliers,Err)
  !Specify the type of interface condition operator
  CALL CMISSInterfaceConditionOperatorSet(InterfaceCondition,CMISSInterfaceConditionFieldContinuityOperator,Err)
  !Add in the dependent variables from the equations sets
  CALL CMISSInterfaceConditionDependentVariableAdd(InterfaceCondition,Mesh1Index,EquationsSet1, &
    & CMISSFieldUVariableType,Err)
  CALL CMISSInterfaceConditionDependentVariableAdd(InterfaceCondition,Mesh2Index,EquationsSet2, &
    & CMISSFieldUVariableType,Err)
  !Finish creating the interface condition
  CALL CMISSInterfaceConditionCreateFinish(InterfaceCondition,Err)

  !Create the Lagrange multipliers field
  PRINT *, ' == >> CREATING INTERFACE LAGRANGE FIELD << == '
  CALL CMISSFieldTypeInitialise(LagrangeField,Err)
  CALL CMISSInterfaceConditionLagrangeFieldCreateStart(InterfaceCondition,LagrangeFieldUserNumber,LagrangeField,Err)
  !Finish the Lagrange multipliers field
  CALL CMISSInterfaceConditionLagrangeFieldCreateFinish(InterfaceCondition,Err)

  !Create the interface condition equations
  PRINT *, ' == >> CREATING INTERFACE EQUATIONS << == '
  CALL CMISSInterfaceEquationsTypeInitialise(InterfaceEquations,Err)
  CALL CMISSInterfaceConditionEquationsCreateStart(InterfaceCondition,InterfaceEquations,Err)
  !Set the interface equations sparsity
  CALL CMISSInterfaceEquationsSparsitySet(InterfaceEquations,CMISSEquationsSparseMatrices,Err)
  !Set the interface equations output
  CALL CMISSInterfaceEquationsOutputTypeSet(InterfaceEquations,CMISSEquationsMatrixOutput,Err)
  !Finish creating the interface equations
  CALL CMISSInterfaceConditionEquationsCreateFinish(InterfaceCondition,Err)

  !
  !================================================================================================================================
  !

  !PROBLEMS
  
  !Start the creation of a coupled problem.
  PRINT *, ' == >> CREATING PROBLEM << == '
  CALL CMISSProblemTypeInitialise(CoupledProblem,Err)
  CALL CMISSProblemCreateStart(CoupledProblemUserNumber,CoupledProblem,Err)
  !Set the problem to be a standard Laplace problem
  CALL CMISSProblemSpecificationSet(CoupledProblem,CMISSProblemClassicalFieldClass, &
    & CMISSProblemLaplaceEquationType,CMISSProblemStandardLaplaceSubtype,Err)
  !Finish the creation of a problem.
  CALL CMISSProblemCreateFinish(CoupledProblem,Err)

  !
  !================================================================================================================================
  !

  !SOLVERS

  !Start the creation of the problem control loop for the coupled problem
  PRINT *, ' == >> CREATING PROBLEM CONTROL LOOP << == '
  CALL CMISSProblemControlLoopCreateStart(CoupledProblem,Err)
  !Finish creating the problem control loop
  CALL CMISSProblemControlLoopCreateFinish(CoupledProblem,Err)
 
  !Start the creation of the problem solver for the coupled problem
  PRINT *, ' == >> CREATING PROBLEM SOLVERS << == '
  CALL CMISSSolverTypeInitialise(CoupledSolver,Err)
  CALL CMISSProblemSolversCreateStart(CoupledProblem,Err)
  CALL CMISSProblemSolverGet(CoupledProblem,CMISSControlLoopNode,1,CoupledSolver,Err)
  !CALL CMISSSolverOutputTypeSet(CoupledSolver,CMISSSolverNoOutput,Err)
  !CALL CMISSSolverOutputTypeSet(CoupledSolver,CMISSSolverProgressOutput,Err)
  !CALL CMISSSolverOutputTypeSet(CoupledSolver,CMISSSolverTimingOutput,Err)
  !CALL CMISSSolverOutputTypeSet(CoupledSolver,CMISSSolverSolverOutput,Err)
  CALL CMISSSolverOutputTypeSet(CoupledSolver,CMISSSolverSolverMatrixOutput,Err)
  CALL CMISSSolverLinearTypeSet(CoupledSolver,CMISSSolverLinearDirectSolveType,Err)
  CALL CMISSSolverLibraryTypeSet(CoupledSolver,CMISSSolverMUMPSLibrary,Err)
  !Finish the creation of the problem solver
  CALL CMISSProblemSolversCreateFinish(CoupledProblem,Err)


  !
  !================================================================================================================================
  !

  !SOLVER EQUATIONS

  !Start the creation of the problem solver equations for the coupled problem
  PRINT *, ' == >> CREATING PROBLEM SOLVER EQUATIONS << == '
  CALL CMISSSolverTypeInitialise(CoupledSolver,Err)
  CALL CMISSSolverEquationsTypeInitialise(CoupledSolverEquations,Err)
  CALL CMISSProblemSolverEquationsCreateStart(CoupledProblem,Err)
  !Get the solve equations
  CALL CMISSProblemSolverGet(CoupledProblem,CMISSControlLoopNode,1,CoupledSolver,Err)
  CALL CMISSSolverSolverEquationsGet(CoupledSolver,CoupledSolverEquations,Err)
  !Set the solver equations sparsity
  CALL CMISSSolverEquationsSparsityTypeSet(CoupledSolverEquations,CMISSSolverEquationsSparseMatrices,Err)
  !CALL CMISSSolverEquationsSparsityTypeSet(CoupledSolverEquations,CMISSSolverEquationsFullMatrices,Err)  
  !Add in the first equations set
  CALL CMISSSolverEquationsEquationsSetAdd(CoupledSolverEquations,EquationsSet1,EquationsSet1Index,Err)
  !Add in the second equations set
  CALL CMISSSolverEquationsEquationsSetAdd(CoupledSolverEquations,EquationsSet2,EquationsSet2Index,Err)
  !Add in the interface condition
! ! !   CALL CMISSSolverEquationsInterfaceConditionAdd(CoupledSolverEquations,InterfaceCondition,InterfaceConditionIndex,Err)
  !Finish the creation of the problem solver equations
  CALL CMISSProblemSolverEquationsCreateFinish(CoupledProblem,Err)

  !
  !================================================================================================================================
  !


!   !BOUNDARY CONDITIONS
! 
   !Start the creation of the equations set boundary conditions for the first equations set
  PRINT *, ' == >> CREATING BOUNDARY CONDITIONS << == '
  CALL CMISSBoundaryConditionsTypeInitialise(BoundaryConditions,Err)
  CALL CMISSSolverEquationsBoundaryConditionsCreateStart(CoupledSolverEquations,BoundaryConditions,Err)
  !Set the first node to 0.0
  FirstNodeNumber=110
  CALL CMISSDecompositionNodeDomainGet(Decomposition1,FirstNodeNumber,1,FirstNodeDomain,Err)
  IF(FirstNodeDomain==ComputationalNodeNumber) THEN
    CALL CMISSBoundaryConditionsSetNode(BoundaryConditions,DependentField1,CMISSFieldUVariableType,1,1,FirstNodeNumber,1, &
      & CMISSBoundaryConditionFixed,1.0_CMISSDP,Err)
  ENDIF
!   
   !Set boundary conditions for second dependent field
  !Set the last node 125 to 1.0
  CALL CMISSNodesTypeInitialise(Nodes,Err)
  CALL CMISSRegionNodesGet(Region2,Nodes,Err)
  LastNodeNumber=1
  CALL CMISSDecompositionNodeDomainGet(Decomposition2,LastNodeNumber,1,LastNodeDomain,Err)
  IF(LastNodeDomain==ComputationalNodeNumber) THEN
    CALL CMISSBoundaryConditionsSetNode(BoundaryConditions,DependentField2,CMISSFieldUVariableType,1,1,LastNodeNumber,1, &
      & CMISSBoundaryConditionFixed,0.0_CMISSDP,Err)
  ENDIF
   CALL CMISSSolverEquationsBoundaryConditionsCreateFinish(CoupledSolverEquations,Err)

  !
  !================================================================================================================================
  !

  !RUN SOLVERS

  !Solve the problem
  PRINT *, ' == >> SOLVING PROBLEM << == '
  CALL CMISSProblemSolve(CoupledProblem,Err)

  !Export the fields
  PRINT *, ' == >> EXPORTING FIELDS << == '
  CALL CMISSFieldsTypeInitialise(Fields1,Err)
  CALL CMISSFieldsTypeCreate(Region1,Fields1,Err)
  CALL CMISSFieldIONodesExport(Fields1,"CoupledLaplace_1","FORTRAN",Err)
  CALL CMISSFieldIOElementsExport(Fields1,"CoupledLaplace_1","FORTRAN",Err)
  CALL CMISSFieldsTypeFinalise(Fields1,Err)
  CALL CMISSFieldsTypeInitialise(Fields2,Err)
  CALL CMISSFieldsTypeCreate(Region2,Fields2,Err)
  CALL CMISSFieldIONodesExport(Fields2,"CoupledLaplace_2","FORTRAN",Err)
  CALL CMISSFieldIOElementsExport(Fields2,"CoupledLaplace_2","FORTRAN",Err)
  CALL CMISSFieldsTypeFinalise(Fields2,Err)
  CALL CMISSFieldsTypeInitialise(InterfaceFields,Err)
  CALL CMISSFieldsTypeCreate(INTERFACE,InterfaceFields,Err)
  CALL CMISSFieldIONodesExport(InterfaceFields,"CoupledLaplace_Interface","FORTRAN",Err)
  CALL CMISSFieldIOElementsExport(InterfaceFields,"CoupledLaplace_Interface","FORTRAN",Err)
  CALL CMISSFieldsTypeFinalise(InterfaceFields,Err)
  
  !Finialise CMISS
  CALL CMISSFinalise(Err)

  WRITE(*,'(A)') "Program successfully completed."

  STOP
 
CONTAINS

  SUBROUTINE HANDLE_ERROR(ERROR_STRING)

    CHARACTER(LEN=*), INTENT(IN) :: ERROR_STRING

    WRITE(*,'(">>ERROR: ",A)') ERROR_STRING(1:LEN_TRIM(ERROR_STRING))
    STOP

  END SUBROUTINE HANDLE_ERROR
     
END PROGRAM THREEDCOUPLEDLAPLACE
