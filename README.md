# Database Sherlock
Project for a university database course

## Цель проекта
Получение практических навыков работы с промышленными СУБД, проектирование БД (концептуальное, логическое, физическое), создание хранимых процедур, представлений, триггеров, индексов.

## Ход выполнения проекта
### 1. Описание предметной области
База данных для хранения и описания преступлений, представленных в сериале "Sherlock" (BBC). Основные сущности:
1. Преступление
2. Следователь
3. Место преступления
4. Организатор преступления
5. Мотив
6. Жертва

Уточнения:
- Преступлением может являться убийство/ ограбление/ шантаж и тд. 
- В качестве следователей выступают главные действующие лица сериала: Шерлок, Ватсон, Мэри, Майкрофт и другие. 
- Под организатором преступления понимается либо лицо, помогающее реализовать преступление, либо непосредственно тот человек/ группировка, чьими руками это преступление было совершено.
- У преступления всегда есть хотя бы одна жертва.
### 2. Проектирование моделей
#### a. Концептуальная модель 
Связи между сущностями в нотации "воронья лапка":
<img src="/models/conceptual-model-sherlock.png"/>

#### b. Логическая модель 
Описание таблиц и их атрибутного состава с указанием связей в нотации "воронья лапка":
<img src="/models/logical-model-sherlock.png"/>

База данных находится во 2-й нормальной форме.

Таблица "CRIME_X_DETECTIVE" является версионной (SCD2) -- можно отслеживать, в какой момент времени каким делом занимался следователь. 

#### c. Физическая модель 
Описание хранения таблиц в СУБД. 
Для каждого объекта пункта 2b приведем таблицу:

1. Таблица 'CRIME':
<img src="/models/physical-model-sherlock/pm-1-crime.png"/>

2. Таблица 'DETECTIVE':
<img src="/models/physical-model-sherlock/pm-2-detective.png"/>

3. Таблица 'PLACE OF CRIME':
<img src="/models/physical-model-sherlock/pm-3-place.png"/>

4. Таблица 'ORGANIZER OF CRIME':
<img src="/models/physical-model-sherlock/pm-4-organizer.png"/>

5. Таблица 'MOTIVE':
<img src="/models/physical-model-sherlock/pm-5-motive.png"/>

6. Таблица 'CRIME VICTIM':
<img src="/models/physical-model-sherlock/pm-6-victim.png"/>

7. Таблица 'CRIME_X_DETECTIVE':
<img src="/models/physical-model-sherlock/pm-7-crime-x-detective.png"/>

8. Таблица 'CRIME_ORGANIZER':
<img src="/models/physical-model-sherlock/pm-8-crime-x-organizer.png"/>

9. Таблица 'CRIME_X_VICTIM':
<img src="/models/physical-model-sherlock/pm-9-crime-x-victim.png"/>
