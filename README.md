# fem-heat-transfer-radiator
2D FEM simulation of heat transfer in a radiator using linear square elements, with configurable geometry, heat source, and boundary conditions.

## Description
This project contains a 2D Finite Element Method (FEM) model of a radiator, implemented with linear square elements.

The radiator geometry consists of a rectangular body with extended top and bottom bases, protruding beyond the main rectangle.  
The outer boundary of the radiator is subject to a Dirichlet condition (fixed temperature), while the center of the body contains a heat source represented by a Neumann condition (prescribed heat flux).

Key features:
- Adjustable mesh density (element size and count)
- Configurable heat source size and position
- Customizable top/bottom base extensions
- Adjustable external temperature and applied heat flux
- Fully parameterized geometry and boundary conditions

This simulation can be used for studying steady-state heat conduction problems with mixed Dirichlet–Neumann boundary conditions in 2D geometries.

