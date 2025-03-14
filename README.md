# NeoCoder

```html
<center>
  <a href="https://odysee.com/@wanderos:4/NeoCoder-Presentacion:e" target="_blank">
    <img src="https://thumbnails.odysee.com/optimize/s:1280:720/quality:85/plain/NeoCoder-Presentacion:e" width="600" style="border-radius: 8px; border: 2px solid #2d2d2d; margin: 20px 0; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
  </a>
  <br>
  <strong style="display: block; font-size: 1.4em; margin: 15px 0; color: #58a6ff;">¡Descubre NeoCoder, el plugin de Neovim que revoluciona tu flujo de trabajo como programador! 🚀</strong>
</center>
```

## Generación de Código Contextual en Neovim

NeoCoder es un plugin innovador para Neovim que revoluciona la forma en que los desarrolladores generan código. Utilizando la potente API de Ollama, NeoCoder permite a los usuarios crear código contextual de manera rápida y eficiente.

## Características Principales

- **Generación Contextual**: Utiliza el contenido actual del buffer para proporcionar contexto relevante.
- **Integración con Ollama**: Aprovecha modelos de lenguaje avanzados para generar código preciso.
- **Activación Intuitiva**: Se activa simplemente escribiendo `##neo: ` seguido de una instrucción.
- **Inserción Automática**: El código generado se inserta seamlessly en la posición deseada.

## Instalación

### Utilizando Packer agrega la linea:

```lua
	use "solimanhub/neocoder"
```
### Utilizando vim-plug agrega la linea:

```lua
    Plug 'solimanhub/neocoder'
```

### Dependencias

> Asegúrate de tener instalada la siguiente dependencia:

```lua
use {
  'nvim-lua/plenary.nvim',
  module = 'plenary'
}
```

Además, necesitarás instalar Ollama:

1. Visita [Ollama](https://ollama.com/download) para más información.

2. Instala Ollama ejecutando el siguiente comando:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

3. Una vez instalado Ollama, instala el modelo qwen2.5-coder:14b con el siguiente comando:

```bash
ollama pull qwen2.5-coder:14b
```

## Configuración

### Configuración del Modelo

NeoCoder fue construido utilizando el modelo `qwen2.5-coder:14b`. Sin embargo, puedes cambiar el modelo utilizado ajustando la variable de entorno. Ten en cuenta que los resultados pueden variar dependiendo del modelo seleccionado.

1. Añade la siguiente línea a tu archivo de configuración de shell (`.zshrc`, `.bashrc`, o similar):

```bash
export MODEL_NEOCODER="qwen2.5-coder:14b"
```

Ajusta las siguientes variables según tu configuración de Ollama:

```lua
local ollama_host = "http://localhost:11434"
local model_name = vim.env.MODEL_NEOCODER or "qwen2.5-coder:14b"
```

## Uso

1. En una nueva línea, escribe `##neo: ` seguido de tu instrucción para generar código.
2. Presiona Enter para activar NeoCoder.
3. El plugin enviará tu instrucción junto con el contexto actual a Ollama.
4. El código generado se insertará automáticamente en la posición del cursor.

## Ejemplo de Uso

```
# Archivo actual: script.sh
echo "Hola Mundo"

##neo: agregar una función que sume dos números
```

Después de presionar Enter, NeoCoder podría generar:

```bash
# Archivo actual: script.sh
echo "Hola Mundo"

suma() {
    local num1=$1
    local num2=$2
    echo $((num1 + num2))
}
```

## Funcionamiento Interno

1. **Detección de Instrucción**: NeoCoder identifica la línea que comienza con `##neo: `.
2. **Recopilación de Contexto**: Captura el contenido completo del buffer actual.
3. **Consulta a Ollama**: Envía la instrucción y el contexto a la API de Ollama.
4. **Procesamiento de Respuesta**: Limpia y filtra la respuesta para extraer solo el código relevante.
5. **Inserción de Código**: Inserta el código generado en la posición correcta del buffer.

## Personalización

NeoCoder es altamente personalizable. Puedes ajustar parámetros como la temperatura de generación o el modelo utilizado modificando el código fuente según tus necesidades específicas.

## Consideraciones

- El rendimiento puede variar dependiendo de la complejidad de la instrucción y el tamaño del contexto.
- La calidad y estilo del código generado pueden cambiar si se utiliza un modelo diferente al predeterminado (`qwen2.5-coder:14b`).

NeoCoder transforma tu experiencia de codificación en Neovim, permitiéndote generar código de manera rápida y contextual, mejorando significativamente tu productividad como desarrollador.

