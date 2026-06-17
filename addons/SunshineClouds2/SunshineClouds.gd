# gdlint: ignore=max-file-lines,class-definitions-order,unused-argument
@tool
class_name SunshineCloudsGD
extends CompositorEffect
@export_tool_button("Refresh Compute", "Clear") var refresh_action = refresh_compute
@export_group("Basic Settings")
@export_range(0, 1) var clouds_coverage : float = 0.874
@export_range(0, 20) var clouds_density : float = 0.14
@export_range(0, 2) var atmospheric_density : float = 0.503
@export_range(0, 10) var lighting_density : float = 0.982
@export_range(0, 1) var fog_effect_ground : float = 1.0
@export_range(0, 1) var use_environment_fog : float = 0.0
@export_subgroup("Colors")
@export_range(0, 1) var clouds_anisotropy : float = 0.16
@export_range(0, 1) var clouds_powder : float = 0.5
@export var cloud_ambient_color : Color = Color(0.761, 0.784, 0.824, 1.0)
@export var cloud_ambient_tint : Color = Color(0.133, 0.2, 0.243, 1.0)
@export var atmosphere_color : Color = Color(1.0, 1.0, 1.0, 1.0)
@export var sampled_environment_fog_color : Color = Color(0.518, 0.553, 0.608, 1.0)
@export var ambient_occlusion_color : Color = Color(1.0, 0.0, 0.0, 1.0)
@export_subgroup("Structure")
@export_range(0, 1) var accumulation_decay : float = 0.7
@export_range(100, 1000000) var extra_large_noise_scale : float = 320000.0
@export_range(100, 500000) var large_noise_scale : float = 120000.0
@export_range(100, 100000) var medium_noise_scale : float = 20000.0
@export_range(100, 10000) var small_noise_scale : float = 8500
@export_range(0, 2) var clouds_sharpness : float = 0.746
@export_range(0, 3) var clouds_detail_power : float = 1.075
@export_range(0, 50000) var curl_noise_strength : float = 4500.0
@export_range(0, 2) var lighting_sharpness : float = 0.38
@export_range(0, 1) var wind_swept_range : float = 0.54
@export_range(0, 5000) var wind_swept_strength : float = 0.0
@export var cloud_floor : float = 1500.0
@export var cloud_ceiling : float = 25000.0
@export_subgroup("Performance")
@export var max_step_count : float = 300
@export var max_lighting_steps : float = 32
@export_enum("Native","Half","Quarter","Eighth") var resolution_scale = 1:
	get:
		return resolution_scale
	set(value):
		resolution_scale = value
		last_size = Vector2i(0, 0)
		lights_updated = true
@export_range(0, 2) var lod_bias : float = 1.0
@export_subgroup("Noise Textures")
@export var dither_noise : Texture3D
@export var height_gradient : Texture2D
@export var extra_large_noise_patterns : Texture2D
@export var large_scale_noise : Texture3D
@export var medium_scale_noise : Texture3D
@export var small_scale_noise : Texture3D
@export var curl_noise : Texture3D
@export_group("Advanced Settings")
@export_subgroup("Visuals")
@export_range(0, 1000) var dither_speed : float = 15.111
@export_range(0, 20) var blur_power : float = 2.0
@export_range(0, 6) var blur_quality : float = 1.0
@export_subgroup("Reflections")
@export var reflections_globalshaderparam : String = ""
@export_subgroup("Performance")
@export var min_step_distance : float = 400.0
@export var max_step_distance : float = 500.0
@export var lighting_travel_distance : float = 10000.0
@export_subgroup("Mask")
@export var extra_large_used_as_mask : bool = false
@export var mask_width_km : float = 32.0;
@export_group("Compute Shaders")
@export var pre_pass_compute_shader : RDShaderFile
@export var compute_shader : RDShaderFile
@export var post_pass_compute_shader : RDShaderFile
@export_group("Internal Use")
@export var origin_offset : Vector3 = Vector3.ZERO
@export_subgroup("Positions")
@export var wind_direction : Vector3 = Vector3.ZERO
# gdlint: disable=class-definitions-order
var extra_large_scale_clouds_position : Vector3 = Vector3.ZERO
# gdlint: disable=class-definitions-order
var large_scale_clouds_position : Vector3 = Vector3.ZERO
# gdlint: disable=class-definitions-order
var medium_scale_clouds_position : Vector3 = Vector3.ZERO
var detail_clouds_position : Vector3 = Vector3.ZERO
var current_time : float = 0.0
@export_subgroup("Lights")
@export var directional_lights_data : Array[Vector4] = []
@export var point_lights_data : Array[Vector4] = []
@export var point_effector_data : Array[Vector4] = []
var position_queries : Array[Vector3] = []
var position_query_callables : Array[Callable] = []
var position_querying : bool = false
var position_resetting : bool = false
var lights_updated: bool = false
var mask_drawn_rid : RID = RID()
var rd : RenderingDevice
var shader : RID = RID()
var pipeline : RID = RID()
var prepass_shader : RID = RID()
var prepass_pipeline : RID = RID()
var postpass_shader : RID = RID()
var postpass_pipeline : RID = RID()
var display_shader : RID = RID()
var display_pipeline : RID = RID()
var display_vertex_format : int
var display_vertex_buffer : RID = RID()
var display_vertex_array : RID = RID()
var framebuffer_format : int
var nearest_sampler : RID = RID()
var linear_sampler : RID = RID()
var linear_sampler_no_repeat : RID = RID()
var general_data_buffer : RID = RID()
var light_data_buffer : RID = RID()
var point_sample_data_buffer : RID = RID()
var accumulation_textures : Array[RID] = []
var resized_depth : RID = RID()
var last_size : Vector2i = Vector2i(0, 0)
var color_images : Array[RID] = []
var blit_screen_images : Array[RID] = []
var buffers : RenderSceneBuffersRD
var uniform_sets : Array[RID] = []
var general_data : PackedByteArray
var light_data : PackedByteArray
var accumulation_is_a : bool = false
var ignore_accumilation : bool = false
var first_run : bool = true
var filter_index: int = 0
var last_render_target : RID
var last_msaa_mode := RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED
var msaa_mode := RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED
func refresh_compute() -> void:
	mask_drawn_rid = RID()
	last_size = Vector2i.ZERO
func update_mask(new_mask : RID) -> void:
	mask_drawn_rid = new_mask
	last_size = Vector2i.ZERO
func add_sample(callable : Callable, position : Vector3) -> void:
	position_queries.append(position)
	position_query_callables.append(callable)
func _init() -> void:
	effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_PRE_TRANSPARENT
	access_resolved_depth = true
	access_resolved_color = true
	needs_motion_vectors = true
	RenderingServer.call_on_render_thread(initialize_compute)
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and is_instance_valid(self):
		RenderingServer.call_on_render_thread(clear_compute)
func clear_compute() -> void:
	if rd:
		if pipeline.is_valid():
			rd.free_rid(pipeline)
		pipeline = RID()
		if shader.is_valid():
			rd.free_rid(shader)
		shader = RID()
		if prepass_pipeline.is_valid():
			rd.free_rid(prepass_pipeline)
		prepass_pipeline = RID()
		if prepass_shader.is_valid():
			rd.free_rid(prepass_shader)
		prepass_shader = RID()
		if postpass_pipeline.is_valid():
			rd.free_rid(postpass_pipeline)
		postpass_pipeline = RID()
		if postpass_shader.is_valid():
			rd.free_rid(postpass_shader)
		postpass_shader = RID()
		if display_pipeline.is_valid():
			rd.free_rid(display_pipeline)
		display_pipeline = RID()
		if display_shader.is_valid():
			rd.free_rid(display_shader)
		display_shader = RID()
		if display_vertex_array.is_valid():
			rd.free_rid(display_vertex_array)
		display_vertex_array = RID()
		if display_vertex_buffer.is_valid():
			rd.free_rid(display_vertex_buffer)
		display_vertex_buffer = RID()
		if nearest_sampler.is_valid():
			rd.free_rid(nearest_sampler)
		nearest_sampler = RID()

		if linear_sampler.is_valid():
			rd.free_rid(linear_sampler)
		linear_sampler = RID()

		if linear_sampler_no_repeat.is_valid():
			rd.free_rid(linear_sampler_no_repeat)
		linear_sampler_no_repeat = RID()

		if general_data_buffer.is_valid():
			rd.free_rid(general_data_buffer)
		general_data_buffer = RID()

		if light_data_buffer.is_valid():
			rd.free_rid(light_data_buffer)
		light_data_buffer = RID()

		if point_sample_data_buffer.is_valid():
			rd.free_rid(point_sample_data_buffer)
		point_sample_data_buffer = RID()

		if resized_depth.is_valid():
			rd.free_rid(resized_depth)
		resized_depth = RID()

		if accumulation_textures.size() > 0:
			for item in accumulation_textures:
				if item.is_valid():
					rd.free_rid(item)
			accumulation_textures.clear()
		if blit_screen_images.size() > 0:
			for item in blit_screen_images:
				if item.is_valid():
					rd.free_rid(item)
			blit_screen_images.clear()
func initialize_compute() -> void:
	first_run = true
	if not rd:
		rd = RenderingServer.get_rendering_device()
		if not rd:
			enabled = false
			printerr("No rendering device on load.")
			return
	clear_compute()

	var sampler_state: Variant = RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	sampler_state.repeat_w = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	nearest_sampler = rd.sampler_create(sampler_state)

	var linear_sampler_state: Variant = RDSamplerState.new()
	linear_sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	linear_sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	linear_sampler_state.repeat_w = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	linear_sampler = rd.sampler_create(linear_sampler_state)

	var linear_sampler_state_no_repeat: Variant = RDSamplerState.new()
	linear_sampler_state_no_repeat.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler_state_no_repeat.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler_state_no_repeat.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	linear_sampler_state_no_repeat.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	linear_sampler_state_no_repeat.repeat_w = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	linear_sampler_no_repeat = rd.sampler_create(linear_sampler_state_no_repeat)

	if not dither_noise:
		# gdlint: disable=max-line-length
		dither_noise = ResourceLoader.load("res://addons/SunshineClouds2/NoiseTextures/bluenoise_Dither.png")
	if not height_gradient:
		# gdlint: disable=max-line-length
		height_gradient = ResourceLoader.load("res://addons/SunshineClouds2/NoiseTextures/HeightGradient.tres")
	if not extra_large_noise_patterns:
		# gdlint: disable=max-line-length
		extra_large_noise_patterns = ResourceLoader.load("res://addons/SunshineClouds2/NoiseTextures/ExtraLargeScaleNoise.tres")
	if not large_scale_noise:
		# gdlint: disable=max-line-length
		large_scale_noise = ResourceLoader.load("res://addons/SunshineClouds2/NoiseTextures/LargeScaleNoise.tres")
	if not medium_scale_noise:
		# gdlint: disable=max-line-length
		medium_scale_noise = ResourceLoader.load("res://addons/SunshineClouds2/NoiseTextures/MediumScaleNoise.tres")
	if not small_scale_noise:
		# gdlint: disable=max-line-length
		small_scale_noise = ResourceLoader.load("res://addons/SunshineClouds2/NoiseTextures/SmallScaleNoise.tres")
	if not curl_noise:
		# gdlint: disable=max-line-length
		curl_noise = ResourceLoader.load("res://addons/SunshineClouds2/NoiseTextures/curl_noise_varied.tga")

	if not compute_shader:
		# gdlint: disable=max-line-length
		compute_shader = ResourceLoader.load("res://addons/SunshineClouds2/SunshineCloudsCompute.glsl")
	if not pre_pass_compute_shader:
		# gdlint: disable=max-line-length
		pre_pass_compute_shader = ResourceLoader.load("res://addons/SunshineClouds2/SunshineCloudsPreCompute.glsl")
	var display_shader_file : RDShaderFile
	if msaa_mode == RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED:
		# gdlint: disable=max-line-length
		post_pass_compute_shader = ResourceLoader.load("res://addons/SunshineClouds2/SunshineCloudsPostCompute.glsl")
		# gdlint: disable=max-line-length
		display_shader_file = ResourceLoader.load("res://addons/SunshineClouds2/SunshineCloudsDisplay.glsl")
	else:
		# gdlint: disable=max-line-length
		post_pass_compute_shader = ResourceLoader.load("res://addons/SunshineClouds2/SunshineCloudsPostCompute.msaa.glsl")
		# gdlint: disable=max-line-length
		display_shader_file = ResourceLoader.load("res://addons/SunshineClouds2/SunshineCloudsDisplay.msaa.glsl")
	# gdlint: disable=max-line-length
	if not compute_shader or not pre_pass_compute_shader or not post_pass_compute_shader or not display_shader_file:

		enabled = false
		printerr("No Shader found on load.")
		clear_compute()
		return

	var prepass_shader_spirv: Variant = pre_pass_compute_shader.get_spirv()
	prepass_shader = rd.shader_create_from_spirv(prepass_shader_spirv)
	if prepass_shader.is_valid():
		prepass_pipeline = rd.compute_pipeline_create(prepass_shader)
	else:
		enabled = false
		printerr("Prepass Shader failed to compile.")
		clear_compute()
		return

	var shader_spirv: Variant = compute_shader.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	if shader.is_valid():
		pipeline = rd.compute_pipeline_create(shader)
	else:
		enabled = false
		printerr("Shader failed to compile.")
		clear_compute()
		return

	var postpass_shader_spirv: Variant = post_pass_compute_shader.get_spirv()
	postpass_shader = rd.shader_create_from_spirv(postpass_shader_spirv)
	if postpass_shader.is_valid():
		postpass_pipeline = rd.compute_pipeline_create(postpass_shader)
	else:
		enabled = false
		printerr("Post pass Shader failed to compile.")
		clear_compute()
		return
	var display_shader_spirv: Variant = display_shader_file.get_spirv()
	display_shader = rd.shader_create_from_spirv(display_shader_spirv)
	if not display_shader.is_valid():
		enabled = false
		printerr("Display Shader failed to compile.")
		clear_compute()
		return
	var display_vertex_attributes : Array[RDVertexAttribute] = [RDVertexAttribute.new()]
	display_vertex_attributes[0].format = RenderingDevice.DataFormat.DATA_FORMAT_R32G32_SFLOAT
	display_vertex_attributes[0].frequency = RenderingDevice.VERTEX_FREQUENCY_VERTEX
	display_vertex_attributes[0].location = 0
	display_vertex_attributes[0].offset = 0
	display_vertex_attributes[0].stride = 8
	display_vertex_format = rd.vertex_format_create(display_vertex_attributes)
	var display_vertex_data : PackedByteArray = PackedFloat32Array([
		-1.0, -1.0,
		1.0, -1.0,
		-1.0,  1.0,
		-1.0,  1.0,
		1.0, -1.0,
		1.0,  1.0,
	]).to_byte_array()
	display_vertex_buffer = rd.vertex_buffer_create(display_vertex_data.size(), display_vertex_data)
	display_vertex_array = rd.vertex_array_create(6, display_vertex_format, [display_vertex_buffer])
	last_msaa_mode = msaa_mode
func initialize_raster_pipelines(color_texture : RID, depth_texture : RID) -> void:
	var rd := RenderingServer.get_rendering_device()
	assert(rd != null)
	var framebuffer_attachmentformats : Array[RDAttachmentFormat] = [ RDAttachmentFormat.new(),
		RDAttachmentFormat.new() ]
	framebuffer_attachmentformats[0].format = rd.texture_get_format(color_texture).format
	framebuffer_attachmentformats[0].samples = rd.texture_get_format(color_texture).samples
	framebuffer_attachmentformats[0].usage_flags = rd.texture_get_format(color_texture).usage_bits
	framebuffer_attachmentformats[1].format = rd.texture_get_format(depth_texture).format
	framebuffer_attachmentformats[1].samples = rd.texture_get_format(depth_texture).samples
	framebuffer_attachmentformats[1].usage_flags = rd.texture_get_format(depth_texture).usage_bits
	framebuffer_format = rd.framebuffer_format_create(framebuffer_attachmentformats);
	var pipeline_rasterization_state := RDPipelineRasterizationState.new()
	var pipeline_multisample_state := RDPipelineMultisampleState.new()
	match msaa_mode:
		RenderingServer.ViewportMSAA.VIEWPORT_MSAA_2X:
			# gdlint: disable=max-line-length
			pipeline_multisample_state.sample_count = RenderingDevice.TextureSamples.TEXTURE_SAMPLES_2
		RenderingServer.ViewportMSAA.VIEWPORT_MSAA_4X:
			# gdlint: disable=max-line-length
			pipeline_multisample_state.sample_count = RenderingDevice.TextureSamples.TEXTURE_SAMPLES_4
		RenderingServer.ViewportMSAA.VIEWPORT_MSAA_8X:
			# gdlint: disable=max-line-length
			pipeline_multisample_state.sample_count = RenderingDevice.TextureSamples.TEXTURE_SAMPLES_8
		_:
			# gdlint: disable=max-line-length
			pipeline_multisample_state.sample_count = RenderingDevice.TextureSamples.TEXTURE_SAMPLES_1
	var pipeline_depthstencil_state := RDPipelineDepthStencilState.new()
	var pipeline_colorblend_state := RDPipelineColorBlendState.new()
	var pipeline_colorblend_state_attachment := RDPipelineColorBlendStateAttachment.new()
	pipeline_colorblend_state.attachments.append(pipeline_colorblend_state_attachment)
	display_pipeline = rd.render_pipeline_create(
		display_shader, framebuffer_format, display_vertex_format,
		RenderingDevice.RenderPrimitive.RENDER_PRIMITIVE_TRIANGLES,
		pipeline_rasterization_state, pipeline_multisample_state,
		pipeline_depthstencil_state, pipeline_colorblend_state)
func _render_callback(_effect_callback_type: int, render_data: RenderData) -> void:

	if rd == null:
		initialize_compute()
	elif pipeline.is_valid() and height_gradient and extra_large_noise_patterns \
		and large_scale_noise and medium_scale_noise and small_scale_noise \
		and dither_noise and curl_noise:
		buffers = render_data.get_render_scene_buffers() as RenderSceneBuffersRD
		if buffers:
			msaa_mode = buffers.get_msaa_3d()
			var is_msaa_on := msaa_mode != RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED
			var size: Variant = buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			var resscale: int = int(pow(2.0, float(resolution_scale)))

			var new_size: Vector2i = size / resscale
			var view_count: int = buffers.get_view_count()
			var render_scene_data : RenderSceneData = render_data.get_render_scene_data();

			if size != last_size or uniform_sets == null or uniform_sets.size() != view_count * 4 \
				or color_images.size() == 0 or color_images[0] != buffers.get_color_layer(0) \
				or blit_screen_images.size() == 0 or msaa_mode != last_msaa_mode:
				initialize_compute()
				initialize_raster_pipelines(buffers.get_color_layer(0, is_msaa_on),
					buffers.get_depth_layer(0, is_msaa_on))
				accumulation_textures.clear()
				uniform_sets.clear()
				color_images.clear()
				for item in blit_screen_images:
					if item.is_valid():
						rd.free_rid(item)
				blit_screen_images.clear()
				for view in range(view_count):
					color_images.append(buffers.get_color_layer(view, false))
					var depth_image : RID = buffers.get_depth_layer(view, false)
					var blank_image_data : PackedByteArray = []
					blank_image_data.resize(new_size.x * new_size.y * 4 * 4)

					# gdlint: disable=max-line-length
					var base_colorformat : RDTextureFormat = rd.texture_get_format(color_images[view])
					# gdlint: disable=max-line-length
					var blit_screen_format : RDTextureFormat = rd.texture_get_format(buffers.get_color_layer(view, is_msaa_on))
					# gdlint: disable=max-line-length
					blit_screen_format.usage_bits |= RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
					blit_screen_images.append(rd.texture_create(blit_screen_format,
						RDTextureView.new()))
					base_colorformat.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
					base_colorformat.width = new_size.x
					base_colorformat.height = new_size.y

					accumulation_textures.append(rd.texture_create(base_colorformat,
						RDTextureView.new(),
						[blank_image_data]))
					accumulation_textures.append(rd.texture_create(base_colorformat,
						RDTextureView.new(),
						[blank_image_data]))
					accumulation_textures.append(rd.texture_create(base_colorformat,
						RDTextureView.new(),
						[blank_image_data]))
					accumulation_textures.append(rd.texture_create(base_colorformat,
						RDTextureView.new(),
						[blank_image_data]))
					accumulation_textures.append(rd.texture_create(base_colorformat,
						RDTextureView.new(),
						[blank_image_data]))
					accumulation_textures.append(rd.texture_create(base_colorformat,
						RDTextureView.new(),
						[blank_image_data]))

					accumulation_textures.append(rd.texture_create(base_colorformat,
						RDTextureView.new(),
						[blank_image_data]))

					general_data_buffer = rd.uniform_buffer_create(256)

					var depthformat : RDTextureFormat = rd.texture_get_format(depth_image)
					depthformat.width = new_size.x
					depthformat.height = new_size.y
					depthformat.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
					# gdlint: disable=max-line-length
					depthformat.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
					resized_depth = rd.texture_create(depthformat, RDTextureView.new(), [])
					var prepass_uniforms_array : Array[RDUniform] = []
					var prepass_depth_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					prepass_depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					prepass_depth_uniform.binding = 0
					prepass_depth_uniform.add_id(nearest_sampler)
					prepass_depth_uniform.add_id(depth_image)
					prepass_uniforms_array.append(prepass_depth_uniform)

					var prepass_depth_output_uniform: Variant = RDUniform.new()
					prepass_depth_output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					prepass_depth_output_uniform.binding = 1
					prepass_depth_output_uniform.add_id(resized_depth)
					prepass_uniforms_array.append(prepass_depth_output_uniform)

					var prepass_camera_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					prepass_camera_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
					prepass_camera_uniform.binding = 2
					prepass_camera_uniform.add_id(general_data_buffer)
					prepass_uniforms_array.append(prepass_camera_uniform)

					uniform_sets.append(rd.uniform_set_create(prepass_uniforms_array,
						prepass_shader, 0))
					var uniforms_array : Array[RDUniform] = []
					var output_data_uniform: Variant = RDUniform.new()
					output_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					output_data_uniform.binding = 0
					output_data_uniform.add_id(accumulation_textures[view * 7])
					uniforms_array.append(output_data_uniform)

					var output_color_uniform: Variant = RDUniform.new()
					output_color_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					output_color_uniform.binding = 1
					output_color_uniform.add_id(accumulation_textures[view * 7 + 1])
					uniforms_array.append(output_color_uniform)

					var accum_1_a_uniform: Variant = RDUniform.new()
					accum_1_a_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					accum_1_a_uniform.binding = 2
					accum_1_a_uniform.add_id(accumulation_textures[view * 7 + 2])
					uniforms_array.append(accum_1_a_uniform)

					var accum_1_b_uniform: Variant = RDUniform.new()
					accum_1_b_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					accum_1_b_uniform.binding = 3
					accum_1_b_uniform.add_id(accumulation_textures[view * 7 + 3])
					uniforms_array.append(accum_1_b_uniform)

					var accum_2_a_uniform: Variant = RDUniform.new()
					accum_2_a_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					accum_2_a_uniform.binding = 4
					accum_2_a_uniform.add_id(accumulation_textures[view * 7 + 4])
					uniforms_array.append(accum_2_a_uniform)

					var accum_2_b_uniform: Variant = RDUniform.new()
					accum_2_b_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					accum_2_b_uniform.binding = 5
					accum_2_b_uniform.add_id(accumulation_textures[view * 7 + 5])
					uniforms_array.append(accum_2_b_uniform)

					var depth_uniform: Variant = RDUniform.new()
					depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					depth_uniform.binding = 6
					depth_uniform.add_id(nearest_sampler)
					depth_uniform.add_id(resized_depth)
					uniforms_array.append(depth_uniform)

					var extra_noise_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					extra_noise_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					extra_noise_uniform.binding = 7
					extra_noise_uniform.add_id(linear_sampler)
					if extra_large_used_as_mask && mask_drawn_rid.is_valid():
						extra_noise_uniform.add_id(mask_drawn_rid)
					else:
						# gdlint: disable=max-line-length
						extra_noise_uniform.add_id(RenderingServer.texture_get_rd_texture(extra_large_noise_patterns.get_rid()))
					uniforms_array.append(extra_noise_uniform)

					var noise_uniform: Variant = RDUniform.new()
					noise_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					noise_uniform.binding = 8
					noise_uniform.add_id(linear_sampler)
					# gdlint: disable=max-line-length
					noise_uniform.add_id(RenderingServer.texture_get_rd_texture(large_scale_noise.get_rid()))
					uniforms_array.append(noise_uniform)

					var medium_noise_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					medium_noise_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					medium_noise_uniform.binding = 9
					medium_noise_uniform.add_id(linear_sampler)
					# gdlint: disable=max-line-length
					medium_noise_uniform.add_id(RenderingServer.texture_get_rd_texture(medium_scale_noise.get_rid()))
					uniforms_array.append(medium_noise_uniform)

					var small_noise_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					small_noise_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					small_noise_uniform.binding = 10
					small_noise_uniform.add_id(linear_sampler)
					# gdlint: disable=max-line-length
					small_noise_uniform.add_id(RenderingServer.texture_get_rd_texture(small_scale_noise.get_rid()))
					uniforms_array.append(small_noise_uniform)

					var curl_noise_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					curl_noise_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					curl_noise_uniform.binding = 11
					curl_noise_uniform.add_id(linear_sampler)
					# gdlint: disable=max-line-length
					curl_noise_uniform.add_id(RenderingServer.texture_get_rd_texture(curl_noise.get_rid()))
					uniforms_array.append(curl_noise_uniform)

					var dither_noise_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					dither_noise_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					dither_noise_uniform.binding = 12
					dither_noise_uniform.add_id(nearest_sampler)
					# gdlint: disable=max-line-length
					dither_noise_uniform.add_id(RenderingServer.texture_get_rd_texture(dither_noise.get_rid()))
					uniforms_array.append(dither_noise_uniform)

					var height_gradient_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					height_gradient_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					height_gradient_uniform.binding = 13
					height_gradient_uniform.add_id(linear_sampler_no_repeat)
					# gdlint: disable=max-line-length
					height_gradient_uniform.add_id(RenderingServer.texture_get_rd_texture(height_gradient.get_rid()))
					uniforms_array.append(height_gradient_uniform)

					var camera_uniform: Variant = RDUniform.new()
					camera_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
					camera_uniform.binding = 14
					camera_uniform.add_id(general_data_buffer)
					uniforms_array.append(camera_uniform)

					light_data_buffer = rd.uniform_buffer_create(6272)
					var light_data_uniform: Variant = RDUniform.new()
					light_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
					light_data_uniform.binding = 15
					light_data_uniform.add_id(light_data_buffer)
					uniforms_array.append(light_data_uniform)

					var sample_data : PackedByteArray = []
					sample_data.resize(512)
					point_sample_data_buffer = rd.storage_buffer_create(512, sample_data)
					var point_sample_data_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					point_sample_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
					point_sample_data_uniform.binding = 16
					point_sample_data_uniform.add_id(point_sample_data_buffer)
					uniforms_array.append(point_sample_data_uniform)

					var camera_data: Variant = render_scene_data.get_uniform_buffer()
					var camera_data_uniform: Variant = RDUniform.new()
					camera_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
					camera_data_uniform.binding = 17
					camera_data_uniform.add_id(camera_data)
					uniforms_array.append(camera_data_uniform)

					uniform_sets.append(rd.uniform_set_create(uniforms_array, shader, 0))
					var postpass_uniforms_array : Array[RDUniform] = []
					var prepass_color_data_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					prepass_color_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					prepass_color_data_uniform.binding = 0
					prepass_color_data_uniform.add_id(linear_sampler_no_repeat)
					prepass_color_data_uniform.add_id(accumulation_textures[view * 7])
					postpass_uniforms_array.append(prepass_color_data_uniform)

					var prepass_color_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					prepass_color_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					prepass_color_uniform.binding = 1
					prepass_color_uniform.add_id(linear_sampler_no_repeat)
					prepass_color_uniform.add_id(accumulation_textures[view * 7 + 1])
					postpass_uniforms_array.append(prepass_color_uniform)

					var postpass_reflections_uniform: Variant = RDUniform.new()
					postpass_reflections_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					postpass_reflections_uniform.binding = 2
					postpass_reflections_uniform.add_id(accumulation_textures[view * 7 + 6])
					postpass_uniforms_array.append(postpass_reflections_uniform)

					if (reflections_globalshaderparam != ""):
						var new_texture: Variant = Texture2DRD.new()
						new_texture.texture_rd_rid = accumulation_textures[view * 7 + 6]
						RenderingServer.global_shader_parameter_set(reflections_globalshaderparam,
							new_texture)
					var postpass_input_screen_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					postpass_input_screen_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					postpass_input_screen_uniform.binding = 3
					postpass_input_screen_uniform.add_id(nearest_sampler)
					postpass_input_screen_uniform.add_id(buffers.get_color_layer(view, is_msaa_on))
					postpass_uniforms_array.append(postpass_input_screen_uniform)
					var postpass_output_screen_uniform: Variant = RDUniform.new()
					postpass_output_screen_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
					postpass_output_screen_uniform.binding = 4
					postpass_output_screen_uniform.add_id(blit_screen_images[view])
					postpass_uniforms_array.append(postpass_output_screen_uniform)
					var postpass_depth_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					postpass_depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					postpass_depth_uniform.binding = 5
					postpass_depth_uniform.add_id(nearest_sampler)
					postpass_depth_uniform.add_id(buffers.get_depth_layer(view, is_msaa_on))
					postpass_uniforms_array.append(postpass_depth_uniform)

					var postpass_camera_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					postpass_camera_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
					postpass_camera_uniform.binding = 6
					postpass_camera_uniform.add_id(general_data_buffer)
					postpass_uniforms_array.append(postpass_camera_uniform)

					var postpass_light_data_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					postpass_light_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
					postpass_light_data_uniform.binding = 7
					postpass_light_data_uniform.add_id(light_data_buffer)
					postpass_uniforms_array.append(postpass_light_data_uniform)

					var postpass_camera_data_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					postpass_camera_data_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
					postpass_camera_data_uniform.binding = 8
					postpass_camera_data_uniform.add_id(camera_data)
					postpass_uniforms_array.append(postpass_camera_data_uniform)

					uniform_sets.append(rd.uniform_set_create(postpass_uniforms_array,
						postpass_shader, 0))
					var display_uniforms_array : Array[RDUniform] = []
					var display_screen_texture_uniform: Variant = RDUniform.new()
					# gdlint: disable=max-line-length
					display_screen_texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
					display_screen_texture_uniform.binding = 0
					display_screen_texture_uniform.add_id(nearest_sampler)
					display_screen_texture_uniform.add_id(blit_screen_images[view])
					display_uniforms_array.append(display_screen_texture_uniform)
					uniform_sets.append(rd.uniform_set_create(display_uniforms_array,
						display_shader, 0))
				lights_updated = true
			var color_layer: Variant = buffers.get_color_layer(0, is_msaa_on)
			var depth_layer: Variant = buffers.get_depth_layer(0, is_msaa_on)
			var framebuffer := FramebufferCacheRD.get_cache_multipass([color_layer,
				depth_layer], [],
				view_count)
			assert(framebuffer_format == rd.framebuffer_get_format(framebuffer))
			var camera_tr : Transform3D = render_scene_data.get_cam_transform();
			var view_proj : Projection = render_scene_data.get_cam_projection();

			var rendertarget: RID = buffers.get_render_target()
			if rendertarget != last_render_target:
				last_render_target = rendertarget
				ignore_accumilation = true
			else:
				ignore_accumilation = false

			last_size = size

			update_matrices(camera_tr, view_proj, new_size)
			if lights_updated or directional_lights_data.size() == 0:
				update_lights()

			if (!position_querying && !position_resetting && position_queries.size() > 0):
				encode_sample_points()

			var prepass_x_groups: Variant = ((size.x - 1) / 8) + 1
			var prepass_y_groups: Variant = ((size.y - 1) / 8) + 1
			var x_groups: Variant = ((size.x - 1) / 8 / resscale) + 1
			var y_groups: Variant = ((size.y - 1) / 8 / resscale) + 1

			for view in view_count:
				var prepass_list: Variant = rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(prepass_list, prepass_pipeline)
				rd.compute_list_bind_uniform_set(prepass_list, uniform_sets[view * 4], 0)
				rd.compute_list_dispatch(prepass_list, x_groups, y_groups, 1)
				rd.compute_list_end()
				var compute_list: Variant = rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_sets[view * 4 + 1], 0)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
				rd.compute_list_end()
				var postpass_list: Variant = rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(postpass_list, postpass_pipeline)
				rd.compute_list_bind_uniform_set(postpass_list, uniform_sets[view * 4 + 2], 0)
				rd.compute_list_dispatch(postpass_list, prepass_x_groups, prepass_y_groups, 1)
				rd.compute_list_end()
				var display_list := rd.draw_list_begin(framebuffer,
					RenderingDevice.DRAW_DEFAULT_ALL)
				rd.draw_list_bind_render_pipeline(display_list, display_pipeline)
				rd.draw_list_bind_uniform_set(display_list, uniform_sets[view * 4 + 3], 0)
				rd.draw_list_bind_vertex_array(display_list, display_vertex_array)
				rd.draw_list_draw(display_list, false, 1)
				rd.draw_list_end()
			if (!position_resetting && position_querying):
				position_resetting = true
				rd.buffer_get_data_async(point_sample_data_buffer, retrieve_position_queries.bind())
					# gdlint: disable=max-line-length
func retrieve_position_queries(data : PackedByteArray) -> void:

	var idx: int = 0
	while idx < 512 && position_query_callables.size() > 0:
		var position : Vector3 = Vector3.ZERO
		position.x = data.decode_float(idx)
		idx += 4
		position.y = data.decode_float(idx)
		idx += 4
		position.z = data.decode_float(idx)
		idx += 4
		var density: Variant = data.decode_float(idx)
		idx += 4

		position_query_callables[0].call(position, density)
		position_query_callables.remove_at(0)

	position_querying = false
	position_resetting = false
func update_matrices(camera_tr: Transform3D, view_proj: Projection, new_size: Vector2i) -> void:
	var dummy2: Variant = camera_tr
	var dummy3: Variant = view_proj
	if general_data.size() != 256: #64 * 4 bytes for each float = 256.
		general_data.resize(256)

	var idx: int = 0
	filter_index += 1
	if filter_index > 16:
		filter_index = 0
	accumulation_is_a = not accumulation_is_a
	first_run = false

	var width: float = mask_width_km * 1000.0

	if (extra_large_used_as_mask):
		general_data.encode_float(idx, origin_offset.x + (width * 0.5) * -1.0); idx += 4
		general_data.encode_float(idx, origin_offset.y + (width * 0.5) * -1.0); idx += 4
		general_data.encode_float(idx, origin_offset.z + (width * 0.5) * -1.0); idx += 4
		general_data.encode_float(idx, width); idx += 4
	else:
		general_data.encode_float(idx, extra_large_scale_clouds_position.x); idx += 4
		general_data.encode_float(idx, extra_large_scale_clouds_position.y); idx += 4
		general_data.encode_float(idx, extra_large_scale_clouds_position.z); idx += 4
		general_data.encode_float(idx, extra_large_noise_scale); idx += 4

	general_data.encode_float(idx, large_scale_clouds_position.x); idx += 4
	general_data.encode_float(idx, large_scale_clouds_position.y); idx += 4
	general_data.encode_float(idx, large_scale_clouds_position.z); idx += 4
	general_data.encode_float(idx, lighting_sharpness); idx += 4
	general_data.encode_float(idx, medium_scale_clouds_position.x); idx += 4
	general_data.encode_float(idx, medium_scale_clouds_position.y); idx += 4
	general_data.encode_float(idx, medium_scale_clouds_position.z); idx += 4
	general_data.encode_float(idx, lighting_travel_distance); idx += 4
	general_data.encode_float(idx, detail_clouds_position.x); idx += 4
	general_data.encode_float(idx, detail_clouds_position.y); idx += 4
	general_data.encode_float(idx, detail_clouds_position.z); idx += 4
	general_data.encode_float(idx, atmospheric_density); idx += 4
	general_data.encode_float(idx, cloud_ambient_color.r * cloud_ambient_tint.r); idx += 4
	general_data.encode_float(idx, cloud_ambient_color.g * cloud_ambient_tint.g); idx += 4
	general_data.encode_float(idx, cloud_ambient_color.b * cloud_ambient_tint.b); idx += 4
	general_data.encode_float(idx, cloud_ambient_color.a * cloud_ambient_tint.a); idx += 4
	general_data.encode_float(idx, ambient_occlusion_color.r); idx += 4
	general_data.encode_float(idx, ambient_occlusion_color.g); idx += 4
	general_data.encode_float(idx, ambient_occlusion_color.b); idx += 4
	general_data.encode_float(idx, ambient_occlusion_color.a); idx += 4
	general_data.encode_float(idx, lerpf(atmosphere_color.r, sampled_environment_fog_color.r,
		use_environment_fog)); idx += 4
	general_data.encode_float(idx, lerpf(atmosphere_color.g, sampled_environment_fog_color.g,
		use_environment_fog)); idx += 4
	general_data.encode_float(idx, lerpf(atmosphere_color.b, sampled_environment_fog_color.b,
		use_environment_fog)); idx += 4
	general_data.encode_float(idx, lerpf(atmosphere_color.a, sampled_environment_fog_color.a,
		use_environment_fog)); idx += 4
	general_data.encode_float(idx, small_noise_scale); idx += 4
	general_data.encode_float(idx, min_step_distance); idx += 4
	general_data.encode_float(idx, max_step_distance); idx += 4
	general_data.encode_float(idx, lod_bias); idx += 4
	general_data.encode_float(idx, clouds_sharpness); idx += 4
	general_data.encode_float(idx, float(directional_lights_data.size()) / 2.0); idx += 4
	general_data.encode_float(idx, clouds_powder); idx += 4
	general_data.encode_float(idx, clouds_anisotropy); idx += 4
	general_data.encode_float(idx, cloud_floor); idx += 4
	general_data.encode_float(idx, cloud_ceiling); idx += 4
	general_data.encode_float(idx, float(max_step_count)); idx += 4
	general_data.encode_float(idx, float(max_lighting_steps)); idx += 4
	general_data.encode_float(idx, use_environment_fog); idx += 4
	general_data.encode_float(idx, float(blur_power)); idx += 4
	general_data.encode_float(idx, float(blur_quality)); idx += 4
	general_data.encode_float(idx, float(curl_noise_strength)); idx += 4

	general_data.encode_float(idx, wind_direction.x); idx += 4
	general_data.encode_float(idx, wind_direction.z); idx += 4
	general_data.encode_float(idx, fog_effect_ground); idx += 4
	general_data.encode_float(idx, position_queries.size()); idx += 4

	general_data.encode_float(idx, float(point_lights_data.size()) / 2.0); idx += 4
	general_data.encode_float(idx, float(point_effector_data.size()) / 2.0); idx += 4
	general_data.encode_float(idx, wind_swept_range); idx += 4
	general_data.encode_float(idx, wind_swept_strength); idx += 4

	general_data.encode_float(idx, new_size.x); idx += 4
	general_data.encode_float(idx, new_size.y); idx += 4
	general_data.encode_float(idx, large_noise_scale); idx += 4
	general_data.encode_float(idx, medium_noise_scale); idx += 4

	general_data.encode_float(idx, current_time); idx += 4
	general_data.encode_float(idx, clouds_coverage); idx += 4
	general_data.encode_float(idx, clouds_density); idx += 4
	general_data.encode_float(idx, clouds_detail_power); idx += 4

	general_data.encode_float(idx, lighting_density); idx += 4
	general_data.encode_float(idx, accumulation_decay if !ignore_accumilation else 0.0); idx += 4
	if (accumulation_is_a):
		general_data.encode_float(idx, 1.0); idx += 4
	else:
		general_data.encode_float(idx, 0.0); idx += 4

	general_data.encode_float(idx, int(pow(2.0, float(resolution_scale)))); idx += 4

	rd.buffer_update(general_data_buffer, 0, general_data.size(), general_data)
func update_lights() -> void:
	lights_updated = false

	if light_data.size() != 6272: #32 + 1024 + 512 * 4 bytes for each float = 6272.
		light_data.resize(6272)

	if (directional_lights_data.size() == 0): #defaults to having a default light.
		directional_lights_data.append(Vector4(0.5, 1.0, 0.5, 16.0))
		directional_lights_data.append(Vector4(1.0, 1.0, 1.0, 1.0))

	var idx: int = 0
	for i in range(min(directional_lights_data.size(), 8)):
		light_data.encode_float(idx, directional_lights_data[i].x)
		idx += 4
		light_data.encode_float(idx, directional_lights_data[i].y)
		idx += 4
		light_data.encode_float(idx, directional_lights_data[i].z)
		idx += 4
		light_data.encode_float(idx, directional_lights_data[i].w)
		idx += 4

	idx = 128
	for i in range(min(point_lights_data.size(), 256)):
		light_data.encode_float(idx, point_lights_data[i].x)
		idx += 4
		light_data.encode_float(idx, point_lights_data[i].y)
		idx += 4
		light_data.encode_float(idx, point_lights_data[i].z)
		idx += 4
		light_data.encode_float(idx, point_lights_data[i].w)
		idx += 4

	idx = 4224
	for i in range(min(point_effector_data.size(), 128)):
		light_data.encode_float(idx, point_effector_data[i].x)
		idx += 4
		light_data.encode_float(idx, point_effector_data[i].y)
		idx += 4
		light_data.encode_float(idx, point_effector_data[i].z)
		idx += 4
		light_data.encode_float(idx, point_effector_data[i].w)
		idx += 4

	rd.buffer_update(light_data_buffer, 0, light_data.size(), light_data)
func encode_sample_points() -> void:
	position_querying = true
	var sample_points_data_floats : PackedByteArray = []
	sample_points_data_floats.resize(512)

	var idx: int = 0
	while idx < 512 && position_queries.size() > 0:

		sample_points_data_floats.encode_float(idx, position_queries[0].x)
		idx += 4
		sample_points_data_floats.encode_float(idx, position_queries[0].y)
		idx += 4
		sample_points_data_floats.encode_float(idx, position_queries[0].z)
		idx += 4
		sample_points_data_floats.encode_float(idx, 0.0)
		idx += 4
		position_queries.remove_at(0)

	rd.buffer_update(point_sample_data_buffer, 0, sample_points_data_floats.size(),
		sample_points_data_floats)
