import pandas as pd
#датафрейм для заполнения
df_owner = pd.DataFrame(columns=['server', 'disk', 'path', 'owner', 'second_owner', 'memo'])
# читаем excel-таблицу для чистки
df = pd.read_excel('/users/pavelparkin/desktop/resowners-main/owners_2.xlsx', sheet_name = 0, header = 2, skiprows = [0],  index_col = None, names = ['server', 'disk', 'path', 'owner', 'second_owner', 'memo'], usecols=[0,1,2,3,4,5])
# удалим строки где ключевые поля не заполнены
df = df.dropna(subset=['server', 'disk', 'path', 'owner', 'second_owner'])
#с в столбце "Примечание" заменим NaN на пустую строку
df.memo = df.memo.fillna('')
df.to_csv('/users/pavelparkin/desktop/resowners-main/owners_2.csv', sep = ',', index=False)
