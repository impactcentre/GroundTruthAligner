int binarize_simple(bytearray &result, bytearray &image) {
    int threshold = (max(image)+min(image))/2;
    makelike(result,image);
    for(int i=0;i<image.length1d();i++)
        result.at1d(i) = image.at1d(i)<threshold ? 0 : 255;
    return threshold;
}

int binarize_simple(bytearray &image) {
    return binarize_simple(image, image);
}
