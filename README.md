## resowners
### Таблица сетевых ресурсов  
Из плоского exel-файла вида: 
| server   | disk     | path     | owner       | second_owner  | memo
|----------|----------|----------|-------------|---------------|-------------------------
| sever-01 | \\Disk_K | Папка1   | Иванов А.В. | Петров И.К.   | Обязательно согласование
| sever-02 | \\Disk_J | Папка12  | Котов П.П.  | Глотова А.А.  | Доступ на чтение
| sever-12 | \\Disk_X | Папка112 | Васин П.П.  | Пупкин Б.К    | Доступ только бухгалтерии

перебрасываем инфу по владельцам сетевых ресусов в БД следующей структуры.    

![Структура БД](https://github.com/petr0vsk/resowners/blob/main/owners.png)

И делаем веб-интерфейс на Flask