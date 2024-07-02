import argparse
import os
import pathlib
from typing import Callable

from stable_baselines3 import PPO
from stable_baselines3.common.callbacks import CheckpointCallback
from stable_baselines3.common.vec_env.vec_monitor import VecMonitor

from godot_rl.core.utils import can_import
from godot_rl.wrappers.onnx.stable_baselines_export import export_ppo_model_as_onnx
from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv

if can_import("ray"):
    print("WARNING, Stable baselines y ray[rllib] no son compatibles")

arguments = argparse.ArgumentParser(allow_abbrev=False)
arguments.add_argument(
    "--env_path",
    default=None,
    type=str,
    help="El binario de Godot.",
)
arguments.add_argument(
    "--exp_dir",
    default="logs/PPO",
    type=str,
    help="El nombre del directorio del experimento.",
)
arguments.add_argument(
    "--exp_name",
    default="experiment",
    type=str,
    help="El nombre del experimento.",
)
arguments.add_argument(
    "--seed", 
    type=int, 
    default=0, 
    help="Semilla de entrenamiento (numero de generaciones aleatorias del entorno)."
)
arguments.add_argument(
    "--resume_path",
    default=None,
    type=str,
    help="Ruta al modelo de entrenamiento guardado anteriormente.",
)
arguments.add_argument(
    "--save_path",
    default=None,
    type=str,
    help="Ruta donde se guardara el modelo de entrenamiento en formato .zip. Podra ser recuperado posteriormente para su entrenamiento.",
)
arguments.add_argument(
    "--save_frequency",
    default=None,
    type=int,
    help=(
        "Frecuencia de guardado del entrenamiento."
    ),
)
arguments.add_argument(
    "--onnx_path",
    default=None,
    type=str,
    help="Exportar el modelo de entrenamiento en un archivo onnx.",
)
arguments.add_argument(
    "--timesteps",
    default=1_000_000,
    type=int,
    help="Numero de pasos de tiempo que realiza el agente por cada accion y recompensa",
)

arguments.add_argument(
    "--linear_schedule",
    default=False,
    action="store_true",
    help="Tasa de aprendizaje lineal hasta alcanzar 0 en timesteps.",
)

arguments.add_argument(
    "--speedup", 
    default=1, 
    type=int, 
    help="Aceleracion del entrenamiento."
)
arguments.add_argument(
    "--n_parallel",
    default=1,
    type=int,
    help="Numero de ejecuciones del entorno en paralelo.",
)



args, extras = arguments.parse_known_args()

def exportar_onnx():
    # Enforce the extension of onnx and zip when saving model to avoid potential conflicts in case of same name
    # and extension used for both
    if args.onnx_path is not None:
        path_onnx = pathlib.Path(args.onnx_path).with_suffix(".onnx")
        print("Exportar onnx a: " + os.path.abspath(path_onnx))
        export_ppo_model_as_onnx(model, str(path_onnx))


def guardar_entrenamiento():
    if args.save_path is not None:
        zip_save_path = pathlib.Path(args.save_path).with_suffix(".zip")
        print("Entrenamiento guardado en: " + os.path.abspath(zip_save_path))
        model.save(zip_save_path)

def cerrar_entorno():
    try:
        print("Cerrando entorno")
        env.close()
    except Exception as e:
        print("Excepcion producida al cerrar el entorno: ", e)


path_checkpoint = os.path.join(args.exp_dir, args.exp_name + "_checkpoints")
abs_path_checkpoint = os.path.abspath(path_checkpoint)



if args.save_frequency is not None and os.path.isdir(path_checkpoint):
    raise RuntimeError(
        abs_path_checkpoint + " folder already exists. "
        "Use a different --experiment_dir, or --experiment_name,"
        "or if previous checkpoints are not needed anymore, "
        "remove the folder containing the checkpoints. "
    )


env = StableBaselinesGodotEnv(env_path=args.env_path, seed=args.seed, n_parallel=args.n_parallel, speedup=args.speedup)
env = VecMonitor(env)

def linear_schedule(initial_value: float) -> Callable[[float], float]:
    
    def func(progress_remaining: float) -> float:
        return progress_remaining * initial_value
    
    return func

if not os.path.exists(args.exp_dir):
    os.makedirs(args.exp_dir)


if args.resume_path is None:
    learning_rate = 0.0003 if not args.linear_schedule else linear_schedule(0.0003)
    checkpoint_freq = 1000  # Guardar el checkpoint cada 10,000 pasos
    model = PPO("MultiInputPolicy", env, ent_coef=0.0001, verbose=2, n_steps=32, 
        tensorboard_log=args.exp_dir,learning_rate=learning_rate)
else:
    path_zip = pathlib.Path(args.resume_path)
    print("Cargando modelo: " + os.path.abspath(path_zip))
    model = PPO.load(path_zip, env=env, tensorboard_log=args.exp_dir)



learn_arguments = dict(total_timesteps=args.timesteps, tb_log_name=args.exp_name)
if args.save_frequency:
    print("El checkpoint se guardara en: " + abs_path_checkpoint)
    checkpoint_callback = CheckpointCallback(save_freq=(args.save_frequency // env.num_envs),
        save_path=path_checkpoint, name_prefix=args.exp_name,)
    learn_arguments["callback"] = checkpoint_callback
try:
    model.learn(**learn_arguments)
except KeyboardInterrupt:
    print("""Se ha interrumpido el entrenamiento.""")


cerrar_entorno()
exportar_onnx()
guardar_entrenamiento()