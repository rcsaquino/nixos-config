function pdfpp
    rm -rf ~/Downloads/tmp_pdfpp
    mkdir ~/Downloads/tmp_pdfpp
    pdftoppm -jpeg ~/Downloads/tmp.pdf ~/Downloads/tmp_pdfpp/page
    xdg-open ~/Downloads/tmp_pdfpp
    rm -rf ~/Downloads/tmp.pdf
end