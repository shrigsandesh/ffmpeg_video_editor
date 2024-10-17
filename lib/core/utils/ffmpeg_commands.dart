String grayscaleCommand(
        {required String inputVideoPath, required String outputVideoPath}) =>
    '-i $inputVideoPath -vf "hue=s=0" $outputVideoPath';

String joinCommand(
        {required String inputfilesPath, required String outputVideoPath}) =>
    "-f concat -safe 0 -i $inputfilesPath -c copy $outputVideoPath";

String trimCommand(
        {required String inputVideoPath,
        required String outputVideoPath,
        required String start,
        required String end}) =>
    '-i $inputVideoPath -ss $start -to $end -c copy $outputVideoPath';
