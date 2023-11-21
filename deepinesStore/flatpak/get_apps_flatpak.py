import requests

# Categorias de app en flathub
categories = [
        "AudioVideo", "Development", "Education", "Games", "Game", "Productivity",
        "Graphics", "Network", "Office", "Science", "System", "Utility"
    ]

# Obtenemos  las apps desde el api de flathub
def fetch_list_app_flatpak():
    api_url = "https://flathub.org/api/v1/apps"
    try:
        response = requests.get(api_url)
        lista = list()
        for app in response.json():
            titulo = app['name']
            descripcion = app['summary']
            categoria= "None"
            estado= 1
            install = app['flatpakAppId']
            lista_origen = [titulo, descripcion,
                            categoria, estado, install]
            lista.append(lista_origen)
            

    except Exception as e:
        print("Error fetching apps:", e)
        return []
    return lista      


def fetch_apps_by_category(category):
        try:
            api_url = f"https://flathub.org/api/v1/apps/category/{category}"
            response = requests.get(api_url)
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print(f"Error fetching apps in category {category}:", e)
            return []

def add_apps_dict_by_categories():
    app_data = {}
    for category in categories:
        app_data[category] = fetch_apps_by_category(category)
    return app_data

def apps_flatpak_in_categories():
    app_data = add_apps_dict_by_categories()
    lista = list()

    for category in categories:
        for app in app_data[category]:
            titulo = app['name']
            descripcion = app['summary']
            categoria= category
            estado= 1
            install = app['flatpakAppId']
            lista_origen = [titulo, descripcion,
                            categoria, estado, install]
            lista.append(lista_origen)
    
    return lista