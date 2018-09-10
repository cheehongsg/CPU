# CPU
ChIA-PET Utilities

CPU was conceived and developed in 2014 as Dr Wei lab developed ChIA-PET Nextera dual-linker. This differs from ChIA-PET MmeI as the tags are now variable length and tagmentation is used rather than MmeI. The lengthy execution time of the original ChIA-PET Tools along with my preference of comprehesive analysis motivated the CPU development. Meanwhile, Dr Ruan lab developed the ChIA-PET bridge linker where a single-linker instead of dual linkers. I call this the ChIA-PET Nextera single-linker.

CPU uses [SSW Library](https://github.com/ekg/ssw), an SIMD Smith-Waterman C/C++ Library for Use in Genomic Applications, to perform linkers and adapters detection.

CPU uses [BWA](https://github.com/lh3/bwa) aln and mem to perform tag to genome mapping accordingly to the tag length.

CPU performs de-duplication to remove PCR duplicate by considering the paired tags' 5' genomic position, and the identified linkers along with the 3' genomic position. In essence, when there is evidence that the paired tags are not from the same molecule (product of PCR), CPU will not consider the paired tags as possibly PCR duplicated.

The proximal non-redundant paired tags are clustered by CPU to consolidate interaction anchors and the corresponding interaction frequency (iPET count). ChiaSigScaled (https://github.com/cheehongsg/ChiaSigScaled), a scalable re-implementation of [ChiaSig](http://folk.uio.no/jonaspau/chiasig/), is used to assess the statistical significance of the interactions.
