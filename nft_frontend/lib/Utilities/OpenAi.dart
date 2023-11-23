import 'package:dart_openai/dart_openai.dart';

// Will End in 2024 14 Feb. After that CC must.
const OPEN_AI_API_KEY = "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";

class OpenAiSdk {
  Future<String> getCompleteDescription(String prompt) async {
    OpenAIChatCompletionModel result = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    return result.choices.first.message.content;
  }

  Future<String?> makeImage(String prompt) async {
    OpenAIImageModel image = await OpenAI.instance.image.create(
      prompt: prompt,
      n: 1,
      size: OpenAIImageSize.size1024,
      responseFormat: OpenAIImageResponseFormat.url,
    );
    return image.data[0].url;
  }
}
