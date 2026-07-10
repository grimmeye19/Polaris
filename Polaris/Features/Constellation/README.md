# Constelacion v0

Constelacion v0 es una representacion visual derivada de Momentos. No existe una entidad persistida `Constellation` y no debe agregarse una para Polaris 0.1.

Cada estrella representa un `Moment` existente. La vista puede usar datos derivados para posicionar y mostrar estrellas, pero la Constelacion no debe guardar estado propio ni duplicar memoria.

El renderer visual debe poder reemplazarse en futuras versiones sin rehacer el modelo de datos. Mantener la implementacion desacoplada de `Moment`, `Expedition` e `History` tanto como sea razonable permite evolucionar hacia una experiencia visual mas rica sin cambiar la base conceptual.

Polaris 0.1 no incluye:

- 3D.
- Shaders.
- Simulacion astronomica.
- Avatar.
- Isla interactiva.
- Animaciones pesadas.

La responsabilidad de este modulo es mostrar una representacion simple, clara y contemplativa de Momentos como estrellas.
