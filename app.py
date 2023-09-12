from flask import Flask, render_template, request
from database_helper import get_total_records, get_records, get_servers, get_owners

app = Flask(__name__)

LIMIT = 30  # количество записей на одной странице


@app.route('/', methods=['POST', 'GET'])
def index():
    page = request.args.get('page', 1, type=int)  # получим текущую страницу
    offset = (page - 1) * LIMIT  # получим смещение

    servers = get_servers()  # список серверов для выпадающего меню
    selected_server = request.args.get('server')
    if selected_server == "ALL":  # обработаем п.меню для возврата к выбору всех серверов
        selected_server = None

    owners = get_owners()  # список владельцев для выпадающего меню
    selected_owner = request.args.get('owner')
    if selected_owner == "ALL":
        selected_owner = None

    total = get_total_records(selected_server, selected_owner)
    data = get_records(selected_server, selected_owner, LIMIT, offset)
    pages = range(1, total // LIMIT + 2)

    return render_template('home.html', data=data, pages=pages, current_page=page, servers=servers,
                           selected_server=selected_server, owners=owners, selected_owner=selected_owner)


if __name__ == '__main__':
    app.run(debug=True)
