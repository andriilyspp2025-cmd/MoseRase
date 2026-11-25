# MoseRase

Моделі чотириколісного робота для перегонів по лінії. Оберіть конструкцію за моторами й способом повороту. На сторінці кожної моделі є перелік деталей та інструкція зі складання.

## Основна модель · чотири GA12-N20

Кожен мотор обертає своє колесо. Для першої збірки з L298 і подальшого переходу на два DRV8833 виберіть раму зі змінною пластиною. Обидві пластини кріпляться двома гвинтами M3.

| Збірка з L298 | Збірка з двома DRV8833 |
| --- | --- |
| [![Чотири N20 та L298](n20/assembly.png)](n20/assembly.png) | [![Чотири N20 та два DRV8833](n20/dual-drv8833.png)](n20/dual-drv8833.png) |
| [Пластина L298](n20/stl/l298-adapter.stl) | [Пластина для двох DRV8833](n20/stl/dual-drv8833-adapter.stl) |

[Відкрити проєкт N20](n20/) · [Деталі STL](n20/stl/) · [Модель OpenSCAD](N20.scad) · [Завантажити комплект ZIP](https://raw.githubusercontent.com/andriilyspp2025-cmd/MoseRase/main/MoseRase-N20.zip)

## Моделі з двома моторами TT

| Проєкт та інструкція | Як влаштована модель | Файли |
| --- | --- | --- |
| [TT v3 · ремінний 4×4](tt-v3/) | Кожен мотор приводить переднє й заднє колеса свого борту через ремінь GT2. | [Збірка](docs/Rama-v3-u-zbori.png) · [OpenSCAD](MyshachiPerehony.scad) · [ZIP](https://raw.githubusercontent.com/andriilyspp2025-cmd/MoseRase/main/Myshachi-perehony-L298-DRV8833.zip) |
| [TT · передній привід](beltless/) | Два передні колеса ведучі, два задні вільно обертаються. | [Збірка](beltless/MoseRase-bez-remeniv.png) · [OpenSCAD](Beltless.scad) · [ZIP](https://raw.githubusercontent.com/andriilyspp2025-cmd/MoseRase/main/MoseRase-Beltless.zip) |
| [TT · цільна рама 4×4](rigid-4wd/) | По одному мотору на вісь. Серво повертає передній міст. | [Збірка](rigid-4wd/assembly.png) · [OpenSCAD](Rigid4WD.scad) · [ZIP](https://raw.githubusercontent.com/andriilyspp2025-cmd/MoseRase/main/MoseRase-Rigid4WD.zip) |
| [TT · шарнірна рама 4×4](axle-drive/) | По одному мотору на вісь. Серво повертає передню секцію рами. | [Збірка](axle-drive/MoseRase-dvi-osi.png) · [OpenSCAD](AxleDrive.scad) · [ZIP](https://raw.githubusercontent.com/andriilyspp2025-cmd/MoseRase/main/MoseRase-AxleDrive.zip) |
| [TT v3 · турбіни 5015](fan-kit/) | Варіант ремінної рами з камерою під днищем і місцем для однієї або двох турбін. | [Збірка](fan-kit/MoseRase-2x5015.png) · [OpenSCAD](FanKit.scad) · [ZIP](https://raw.githubusercontent.com/andriilyspp2025-cmd/MoseRase/main/MoseRase-FanKit.zip) |
