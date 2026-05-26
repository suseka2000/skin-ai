# convert_to_coreml.py

import coremltools as ct
import tensorflow as tf

# Загрузка модели
model = tf.keras.models.load_model("skin_cancer_model.h5")

# Конвертация в CoreML
mlmodel = ct.convert(
    model,
    inputs=[
        ct.ImageType(
            name="conv2d_input",
            shape=(1, 28, 28, 3),
            scale=1/255.0,
            color_layout="RGB"
        )
    ]
)

# Добавление метаданных
mlmodel.author = "Your Name"
mlmodel.short_description = "Skin cancer classifier for 7 types of lesions"
mlmodel.version = "1.0"

# Добавление описания входов и выходов
mlmodel.input_description["conv2d_input"] = "Input image 28x28 RGB"
mlmodel.output_description["Identity"] = "Probability distribution across 7 classes"

# Сохранение
mlmodel.save("SkinCancerClassifier.mlmodel")

print("Conversion completed successfully!")
print("Model saved as: SkinCancerClassifier.mlmodel")
print("\nClass mapping:")
print("0: akiec - Actinic keratoses")
print("1: bcc - Basal cell carcinoma")
print("2: bkl - Benign keratosis-like lesions")
print("3: df - Dermatofibroma")
print("4: nv - Melanocytic nevi")
print("5: vasc - Pyogenic granulomas")
print("6: mel - Melanoma")
