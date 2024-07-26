import 'package:sfs_editor/models/aimodels_model.dart';

List<AiModels> aiModelsData = [
  AiModels(
      id: 'realvis-xl-v4',
      name: 'RealVisXL V4.0',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'ip-adapter']),
  AiModels(
      id: 'juggernaut-xl-v10',
      name: 'JuggernautXL X',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'ip-adapter']),
  AiModels(
      id: 'reproduction-v3-31',
      name: 'Reproduction v3.31',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'ip-adapter']),
  AiModels(
      id: 'real-cartoon-xl-v6',
      name: 'RealCartoonXL v6',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'ip-adapter']),
  AiModels(
      id: 'sdvn7-niji-style-xl-v1',
      name: 'SDVN7-NijiStyleXLXL',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'ip-adapter']),
  AiModels(
      id: 'counterfeit-xl-v2-5',
      name: 'CounterfeitXL v2.5',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'ip-adapter']),
  AiModels(
      id: 'animagine-xl-v-3-1',
      name: 'Animagine v3.1',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'ip-adapter']),
  AiModels(
      id: 'lcm-dark-sushi-mix-v2-25',
      name: 'Dark Sushi Mix v2.25 LCM',
      family: 'latent-consistency',
      piplines: ['text-to-image', 'image-to-image']),
  AiModels(
      id: 'lcm-realistic-vision-v5-1',
      name: 'Realistic Vision v5.1 LCM',
      family: 'latent-consistency',
      piplines: ['text-to-image', 'image-to-image']),
  AiModels(
      id: 'lcm-dream-shaper-v8',
      name: 'DreamShaper v8 LCM',
      family: 'latent-consistency',
      piplines: ['text-to-image', 'image-to-image']),
  AiModels(
      id: 'absolute-reality-v1-8-1',
      name: 'AbsoluteReality v1.8.1',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'dream-shaper-v8',
      name: 'DreamShaper v8',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'realistic-vision-v5-1',
      name: 'Realistic Vision v5.1',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'icbinp-seco',
      name: 'ICBINP SECO',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'realistic-vision-v5-1-inpainting',
      name: 'Realistic Vision v5.1 Inpainting',
      family: 'stable-diffusion',
      piplines: ['inpaint']),  ////////// inpaint
  AiModels(
      id: 'stable-diffusion-xl-v1-0',
      name: 'Stable Diffusion XL',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'inpaint', 'ip-adapter']),
  AiModels(
      id: 'dark-sushi-mix-v2-25',
      name: 'Dark Sushi Mix v2.25',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'absolute-reality-v1-6',
      name: 'AbsoluteReality v1.6',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'synthwave-punk-v2',
      name: 'SynthwavePunk v2',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'arcane-diffusion',
      name: 'Arcane Diffusion',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'moonfilm-reality-v3',
      name: 'MoonFilm Reality v3',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'moonfilm-utopia-v3',
      name: 'MoonFilm Utopia v3',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'moonfilm-film-grain-v1',
      name: 'MoonFilm FilmGrain v1',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'openjourney-v4',
      name: 'Openjourney v4',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'realistic-vision-v3',
      name: 'Realistic Vision v3',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'icbinp-final',
      name: 'ICBINP Final',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'icbinp-relapse',
      name: 'ICBINP Relapse',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'icbinp-afterburn',
      name: 'ICBINP Afterburn',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'xsarchitectural-interior-design',
      name: 'InteriorDesign',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'mo-di-diffusion',
      name: 'Modern Disney Diffusion',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'anashel-rpg',
      name: 'RPG',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'realistic-vision-v1-3-inpainting',
      name: 'Realistic Vision v1.3 Inpainting',
      family: 'stable-diffusion',
      piplines: ['inpaint']),////////////// inpaint
  AiModels(
      id: 'eimis-anime-diffusion-v1-0',
      name: 'Anime Diffusion',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'something-v2-2',
      name: 'Something V2.2',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'icbinp',
      name: 'ICBINP',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'analog-diffusion',
      name: 'Analog Diffusion',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'neverending-dream',
      name: 'NeverEnding Dream',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'van-gogh-diffusion',
      name: 'Van Gogh Diffusion',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'openjourney-v1-0',
      name: 'Openjourney',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'realistic-vision-v1-3',
      name: 'Realistic Vision v1.3',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet']),
  AiModels(
      id: 'stable-diffusion-v1-5-inpainting',
      name: 'Stable Diffusion Inpainting v1.5',
      family: 'stable-diffusion',
      piplines: ['inpaint']),/////////////////// inpaint
  AiModels(
      id: 'gfpgan-v1-3',
      name: 'GFPGAN v1.3',
      family: 'enhancements',
      piplines: ['face-fix']),//////// face fix
  AiModels(
      id: 'real-esrgan-4x',
      name: 'Real-ESRGAN',
      family: 'enhancements',
      piplines: ['upscale']),////////// upscale
  AiModels(
      id: 'instruct-pix2pix',
      name: 'Instruct Pix2Pix',
      family: 'stable-diffusion',
      piplines: ['instruct']), ////////// instruct
  AiModels(
      id: 'stable-diffusion-v2-1',
      name: 'Stable Diffusion v2.1',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image']),
  AiModels(
      id: 'stable-diffusion-v1-5',
      name: 'Stable Diffusion v1.5',
      family: 'stable-diffusion',
      piplines: ['text-to-image', 'image-to-image', 'controlnet'])
];
