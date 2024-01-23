Pod::Spec.new do |s|
  s.name         = "ValifyFaceDetection"
  s.version      = "1.0.0"
  s.summary      = "Valify's framework for seamless selfie capture and face detection during digital onboarding."
  s.homepage     = "https://github.com/AmrFawzyAbdo/FaceDetectionFrameWork"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Amr Fawzy" => "amfa.94@hotmail.com" }
  s.source       = { :git => "https://github.com/AmrFawzyAbdo/FaceDetectionFrameWork.git", :tag => s.version}
  s.source_files = "ValifyFaceDetection/**/*.swift"
end