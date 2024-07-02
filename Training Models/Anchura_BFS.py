from collections import deque

def bfs(maze, start, end):
    # Direcciones posibles: izquierda, derecha
    directions = [(0, -1), (0, 1)]
    
    queue = deque([(start, [])])  # Inicializa la cola con la posición inicial y una lista de movimientos
    visited = set()  # Conjunto para almacenar las celdas visitadas
    
    while queue:
        current, path = queue.popleft()  # Obtiene el siguiente nodo de la cola
        
        if current == end:
            return path  # Si llegamos al destino, devuelve el camino
            
        for direction in directions:
            new_pos = (current[0] + direction[0], current[1] + direction[1])
            if 0 <= new_pos[0] < len(maze) and 0 <= new_pos[1] < len(maze[0]) and maze[new_pos[0]][new_pos[1]] == 0 and new_pos not in visited:
                queue.append((new_pos, path + [direction]))  # Añade el nuevo nodo a la cola con el camino actualizado
                visited.add(new_pos)  # Marca la celda como visitada
    
    return None  # Si no se encuentra una ruta, devuelve None







# Ejemplo de uso
maze = [
    [0, 0, 0, 0, 1],
    [1, 1, 1, 0, 0],
    [0, 0, 1, 0, 1],
    [0, 0, 0, 0, 0]
]

start = (0, 0)
end = (3, 4)

path = bfs(maze, start, end)
if path:
    print("Ruta encontrada:", path)
else:
    print("No se encontró una ruta.")
