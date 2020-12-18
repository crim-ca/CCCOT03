# Deep Learning Model Extension Specification

- **Title: Deep Learning Model**
- **Identifier: dl-model**
- **Field Name Prefix: dlm**
- **Scope: Item**
- **Extension [Maturity Classification](https://github.com/radiantearth/stac-spec/tree/v1.0.0-beta.2/extensions#extension-maturity): Proposal**

This document explains the fields of the STAC Deep Learning Model (dlm) Extension to a STAC Item. The main objective is to be able to build model collections that can be searched and that are containing enough information to be able to deploy an inference service. When Deep Learning models are trained using satellite imagery, it is important to track essential information if you want to make them searchable and reusable:
1. The input data origin and specifications
2. The model base transforms
3. The model output and its semantic interepretation 
4. The runtime environment to be able to run the model
5. The scientific references

![](https://i.imgur.com/cVAg5sA.png)


- Examples:
  - [Example with a UNet trained with thelper](examples/example-thelper-item.json)

## Item Properties

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| dlm:data       | \[[Data Object](#data-object)] | describes the EO data compatible with the model. |
| dlm:inputs       | \[[Inputs Object](#inputs-object)] | describes the transformation between the EO data and the model inputs. |
| dlm:architecture       | \[[Architecture Object](#architecture-object)] | describes the model architecture. |
| dlm:runtime       | \[[Runtime Object](#runtime-object)] | describes the runtime environments to run the model (inference). |
| dlm:outputs       | \[[Outputs Object](#outputs-object)] | describes the model output and how to interpret it. |

In addition, fields from the following extensions must be imported in the item:
* the [Scientific Extension Specification](https://github.com/radiantearth/stac-spec/tree/v1.0.0-beta.2/extensions/scientific/README.md) to describe relevant publications.
* the [EO Extension Specification](https://github.com/radiantearth/stac-spec/tree/v1.0.0-beta.2/extensions/eo/README.md) to describe eo data.
* the [Version Extension Specification](https://github.com/radiantearth/stac-spec/tree/v1.0.0-beta.2/extensions/version/README.md) to define version tags.

### Data Object

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| process_ level       | enum | Data processing level (L0= raw, L4= ARD). The levels are described by an enum. Important parameter because it can impact the apparent variability of the data. |
| dtype       | enum | Data type (uint8, uint16, etc.) enum based on numpy base types. Potentially important for data normalization and therefore pre-processing. |
| nodata_value       | integer | 'no data' value, may be relevant if the network should ignore this value. |
| number_of_bands       | integer | number of bands used by the model |
| useful_bands       | \[[Outputs Object](#outputs-object)] | describes only the relevant bands for the model, based on the [eo:bands](https://github.com/radiantearth/stac-spec/blob/v1.0.0-beta.2/extensions/eo/README.md#band-object) object but indicates only the relevant bands. |


### Inputs Object

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| name      | string | Python name of the input variable. |
| input_tensors       | \[[Tensor Object](#tensor-object)] | Shape of the input tensor ($N\times C\times H \times W$). |
| scaling_factor      | number | Scaling factor to apply to get data within [0,1]. For instance `scaling_factor=0.004` for 8-bit data. |
| normalization:mean  | list of numbers   | Mean vector value to be removed from the data. The vector size must be consistent with `input_tensors:dim` and `selected_bands`. |
| normalization:std   | list of numbers   | Standard-deviation values used to normalize the data. The vector size must be consistent with `input_tensors:dim` and `selected_bands`. |
| selected_band       | list of integers   | Specifies the bands selected from the data described in dlm:data. |
| pre_processing_function | string | Defines a python pre-processing function (path and inputs should be specified). |

#### Tensor Object

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| batch  | number | Batch size dimension (must be > 0). |
| dim    | number | Number of channels  (must be > 0). |
| height | number | Height of the tensor (must be > 0). |
| width  | number | Width of the tensor (must be > 0). |


### Architecture Object

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| total_nb_parameters  | integer | . |
| estimated_total_size_mb  | number | . |
| summary  | string | . |
| pretrained  | string | . |


### Runtime Object

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| framework  | string | . |
| version  | string | . |
| model_handler  | string | . |
| model_src_url  | string | . |
| model_commit_hash  | string | . |
| model_handler  | string | . |
| docker  | \[[Tensor Object](#docker-object)] | . |

#### Docker Object

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| docker_file  | string | . |
| image_name   | string | . |
| tag          | string | . |
| working_dir  | string | . |
| run          | string | . |
| gpu          | boolean | . |

### Outputs Object

| Field Name     | Type                           | Description |
| -------------- | ------------------------------ | ----------- |
| task              | enum | . |
| number_of_classes | integer | . |
| final_layer_size  | list of integer | . |
| class_name_mapping  | list | . |
| dont_care_index     | integer | . |
| post_processing_function     | string | . |

## Implementations


## Extensions


