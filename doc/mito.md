# Yeast mitochondria


# S288c organelle

## s288cO: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/s288cO
cd ${HOME}/data/anchr/s288cO

mkdir -p 1_genome
cd 1_genome

faops order ${HOME}/data/anchr/s288c/1_genome/genome.fa \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI}; do echo $chr; done) \
    ref.fa

faops order ${HOME}/data/anchr/s288c/1_genome/genome.fa \
    <(echo Mito) \
    genome.fa

```

* Illumina

```bash
mkdir -p ${HOME}/data/anchr/s288cO/2_illumina
cd ${HOME}/data/anchr/s288cO/2_illumina

cp ${HOME}/data/anchr/s288c/2_illumina/ERR1938683_{1,2}.fastq.gz .

ln -s ERR1938683_1.fastq.gz R1.fq.gz
ln -s ERR1938683_2.fastq.gz R2.fq.gz

```

## s288cO: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/anchr/s288cO/ \
    wangq@202.119.37.251:data/anchr/s288cO

# rsync -avP wangq@202.119.37.251:data/anchr/s288cO/ ~/data/anchr/s288cO

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288cO

cd ${WORKING_DIR}/${BASE_NAME}

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 85779 \
    --trim2 "--dedupe --cutoff 150 --cutk 51" \
    --sample2 600 \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80 120 160 240" \
    --tadpole \
    --statp 2 \
    --splitp 200 \
    --statp 2 \
    --redoanchors \
    --fillanchor \
    --parallel 24

```

## s288cO: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288cO

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```

Table: statReads

| Name     |   N50 |     Sum |       # |
|:---------|------:|--------:|--------:|
| Genome   | 85779 |   85779 |       1 |
| Illumina |   150 | 995.54M | 6636934 |
| trim     |   150 |  25.62M |  171262 |
| Q20L60   |   150 |  25.27M |  169771 |
| Q25L60   |   150 |  24.43M |  165441 |
| Q30L60   |   150 |  22.93M |  156956 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 150 | 992.93M | 6619558 |
| highpass | 150 | 192.98M | 1286518 |
| sample   | 150 |  25.73M |  171558 |
| trim     | 150 |  25.63M |  171304 |
| filter   | 150 |  25.62M |  171262 |
| R1       | 150 |  12.82M |   85631 |
| R2       | 150 |   12.8M |   85631 |
| Rs       |   0 |       0 |       0 |


```text
#trim
#Matched	235	0.13698%
#Name	Reads	ReadsPct
```

```text
#filter
#Matched	22	0.01284%
#Name	Reads	ReadsPct
```

```text
#peaks.raw
#k	50
#unique_kmers	43904022
#main_peak	44
#genome_size	14102201
#haploid_genome_size	14102201
#fold_coverage	44
#haploid_fold_coverage	44
#ploidy	1
#percent_repeat	19.247
#start	center	stop	max	volume
18	44	76	605707	11387957	
76	87	122	4209	110735	
122	123	127	733	3389	
127	128	129	694	1361	
129	136	169	723	21147	
169	198	208	344	12035	
208	214	347	307	23113	
347	453	468	146	14744	
468	479	1148	141	20030	
1148	1873	3980	36	10619	
6132	7629	7643	6	4682	
7643	7655	7680	10	258	
7680	7780	7852	10	1015	
7852	7938	8087	7	899	
8087	8249	8649	3	1169	
```

```text
#peaks.highpass
#k	50
#unique_kmers	5617723
#main_peak	143
#genome_size	769888
#haploid_genome_size	256629
#fold_coverage	143
#haploid_fold_coverage	411
#ploidy	3
#het_rate	0.00406
#percent_repeat	84.634
#start	center	stop	max	volume
69	143	170	552	40817	
170	190	192	346	6238	
192	198	208	345	5023	
208	213	300	327	16341	
300	411	435	163	16627	
435	452	471	142	4682	
471	479	489	139	2244	
489	492	1196	124	17247	
1196	1873	3973	37	10461	
5685	7339	7420	7	3550	
7420	7502	7536	8	751	
7536	7628	7640	8	684	
7640	7651	7980	8	1851	
7980	8243	8646	1	1496	
```


Table: statMergeReads

| Name          | N50 |    Sum |      # |
|:--------------|----:|-------:|-------:|
| clumped       | 150 | 25.62M | 171262 |
| ecco          | 150 | 25.62M | 171262 |
| eccc          | 150 | 25.62M | 171262 |
| ecct          | 150 | 23.62M | 157738 |
| extended      | 190 | 29.61M | 157738 |
| merged        | 378 | 20.59M |  55887 |
| unmerged.raw  | 190 |  8.52M |  45964 |
| unmerged.trim | 190 |  8.52M |  45962 |
| U1            | 190 |  4.28M |  22981 |
| U2            | 190 |  4.24M |  22981 |
| Us            |   0 |      0 |      0 |
| pe.cor        | 337 | 29.17M | 157736 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 249.2 |    255 |  27.8 |         19.18% |
| ihist.merge.txt  | 368.4 |    362 |  71.3 |         70.86% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|--------:|---------:|----------:|
| Q0L0   | 298.7 |  265.9 |   10.99% |     149 | "105" | 85.78K | 227.63K |     2.65 | 0:00'11'' |
| Q20L60 | 294.6 |  266.3 |    9.61% |     148 | "105" | 85.78K | 224.63K |     2.62 | 0:00'09'' |
| Q25L60 | 284.9 |  265.1 |    6.95% |     147 | "105" | 85.78K | 218.34K |     2.55 | 0:00'09'' |
| Q30L60 | 267.4 |  254.7 |    4.72% |     146 | "105" | 85.78K | 211.73K |     2.47 | 0:00'08'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |  # | N50Others |    Sum |  # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|---:|----------:|-------:|---:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  45.17% |      3757 | 35.73K | 12 |      1707 |    16K | 42 |   10.0 |  3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q0L0X40P001    |   40.0 |  39.48% |      4324 | 34.77K | 12 |      1168 | 14.79K | 38 |   10.0 |  3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q0L0X40P002    |   40.0 |  38.44% |      2533 | 28.74K | 10 |      1304 | 18.74K | 38 |   10.0 |  5.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'25'' |
| Q0L0X80P000    |   80.0 |  19.26% |      4488 | 39.92K | 11 |      2215 |  8.24K | 31 |   18.0 |  7.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'25'' |
| Q0L0X80P001    |   80.0 |  32.39% |      3021 | 37.43K | 12 |      1126 | 16.13K | 40 |   16.0 |  5.5 |   3.0 |  32.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'25'' |
| Q0L0X80P002    |   80.0 |  33.56% |      4616 |  41.7K | 14 |      2215 |  9.41K | 36 |   21.0 |  8.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q0L0X120P000   |  120.0 |  18.18% |      4516 | 42.67K | 13 |      2215 |  5.62K | 30 |   28.0 |  9.0 |   3.0 |  56.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'25'' |
| Q0L0X120P001   |  120.0 |  19.87% |      4690 | 41.96K | 13 |      1460 |  5.61K | 31 |   31.0 |  8.0 |   3.0 |  62.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'25'' |
| Q0L0X160P000   |  160.0 |  17.99% |      4528 | 41.88K | 13 |      1460 |  6.35K | 31 |   36.0 | 14.0 |   3.0 |  72.0 | "31,41,51,61,71,81" | 0:00'08'' | 0:00'26'' |
| Q0L0X240P000   |  240.0 |  18.40% |      4724 | 40.74K | 13 |      1460 | 10.04K | 34 |   53.0 | 21.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:00'09'' | 0:00'25'' |
| Q20L60X40P000  |   40.0 |  43.27% |      3747 | 36.14K | 12 |      2215 | 12.74K | 32 |   11.0 |  4.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q20L60X40P001  |   40.0 |  41.79% |      5279 | 33.71K | 13 |      2215 | 13.08K | 33 |   10.0 |  5.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q20L60X40P002  |   40.0 |  43.25% |      2443 |  33.9K | 12 |      2215 | 13.14K | 38 |   10.0 |  3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'25'' |
| Q20L60X80P000  |   80.0 |  27.99% |      2948 |  38.6K | 15 |      1582 | 12.22K | 38 |   17.0 |  6.5 |   3.0 |  34.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q20L60X80P001  |   80.0 |  38.90% |      4585 | 39.56K | 10 |      2078 | 12.91K | 37 |   18.0 |  7.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q20L60X80P002  |   80.0 |  40.09% |      3723 | 40.54K | 13 |      1321 | 12.86K | 33 |   20.0 | 10.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q20L60X120P000 |  120.0 |  22.85% |      4615 | 40.77K | 12 |      2215 |  8.43K | 28 |   27.0 | 11.0 |   3.0 |  54.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'25'' |
| Q20L60X120P001 |  120.0 |  26.56% |      4647 | 43.26K | 14 |      2215 |  6.66K | 35 |   32.0 |  8.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'26'' |
| Q20L60X160P000 |  160.0 |  17.77% |      4250 |  41.9K | 13 |      2177 |  6.87K | 29 |   36.0 | 15.0 |   3.0 |  72.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'26'' |
| Q20L60X240P000 |  240.0 |  17.79% |      4252 | 40.25K | 13 |      1460 | 10.02K | 32 |   53.0 | 21.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:00'09'' | 0:00'26'' |
| Q25L60X40P000  |   40.0 |  43.54% |      5430 | 29.92K | 10 |      1713 | 14.79K | 28 |   11.0 |  4.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'25'' |
| Q25L60X40P001  |   40.0 |  51.06% |      2978 | 29.73K | 10 |      2215 | 15.73K | 31 |   10.0 |  4.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'25'' |
| Q25L60X40P002  |   40.0 |  51.34% |      3946 | 33.59K | 10 |      2215 | 14.45K | 30 |   10.0 |  4.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q25L60X80P000  |   80.0 |  38.53% |      4680 | 38.48K | 10 |      1206 | 12.36K | 35 |   17.0 |  6.0 |   3.0 |  34.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q25L60X80P001  |   80.0 |  50.98% |      4458 | 41.46K | 11 |      1543 | 11.96K | 36 |   20.0 |  9.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q25L60X80P002  |   80.0 |  39.84% |      4500 | 38.78K | 10 |      1307 | 14.78K | 40 |   18.0 |  8.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q25L60X120P000 |  120.0 |  32.17% |      4710 | 41.53K | 11 |      1203 |  9.59K | 33 |   27.0 | 10.0 |   3.0 |  54.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'27'' |
| Q25L60X120P001 |  120.0 |  39.21% |      4532 | 42.73K | 12 |      2215 |  9.29K | 33 |   30.0 | 14.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q25L60X160P000 |  160.0 |  30.51% |      4730 | 42.92K | 12 |      1203 |  9.18K | 30 |   37.0 | 16.5 |   3.0 |  74.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'27'' |
| Q25L60X240P000 |  240.0 |  18.12% |      4742 | 40.95K | 12 |      1460 | 10.95K | 31 |   52.0 | 22.0 |   3.0 | 104.0 | "31,41,51,61,71,81" | 0:00'08'' | 0:00'26'' |
| Q30L60X40P000  |   40.0 |  54.71% |      6246 | 31.04K | 11 |      2215 | 17.91K | 33 |   11.0 |  4.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q30L60X40P001  |   40.0 |  53.20% |      2605 | 35.48K | 14 |      2215 | 14.23K | 41 |   11.0 |  4.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q30L60X40P002  |   40.0 |  54.96% |      4607 | 34.78K | 13 |      2215 |  15.2K | 37 |   11.0 |  4.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'25'' |
| Q30L60X80P000  |   80.0 |  53.80% |      3534 | 42.28K | 13 |      2506 | 13.26K | 40 |   20.0 |  9.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q30L60X80P001  |   80.0 |  47.69% |      4672 | 41.54K | 12 |      1453 | 15.35K | 47 |   18.0 |  9.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'25'' |
| Q30L60X80P002  |   80.0 |  53.83% |      3554 | 40.78K | 13 |      1910 | 16.07K | 42 |   20.0 | 10.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q30L60X120P000 |  120.0 |  47.25% |      4706 | 40.47K | 10 |      2016 | 14.51K | 34 |   29.0 | 14.0 |   3.0 |  58.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| Q30L60X120P001 |  120.0 |  53.82% |      3609 | 41.26K | 13 |      1859 | 15.89K | 38 |   29.0 | 13.0 |   3.0 |  58.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'26'' |
| Q30L60X160P000 |  160.0 |  38.98% |      4716 | 43.63K | 13 |      1453 | 10.05K | 34 |   41.0 | 20.5 |   3.0 |  82.0 | "31,41,51,61,71,81" | 0:00'08'' | 0:00'26'' |
| Q30L60X240P000 |  240.0 |  38.03% |      4742 | 43.36K | 13 |      1453 | 11.03K | 33 |   58.0 | 29.0 |   3.0 | 116.0 | "31,41,51,61,71,81" | 0:00'09'' | 0:00'26'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |  # | N50Others |    Sum |  # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|---:|----------:|-------:|---:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  57.35% |      2032 | 37.68K | 18 |      2215 | 21.73K | 51 |   11.0 |  4.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'25'' |
| Q0L0X40P001    |   40.0 |  54.79% |      3437 | 32.21K | 13 |      2506 | 14.66K | 31 |   12.0 |  4.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'25'' |
| Q0L0X40P002    |   40.0 |  54.18% |      2395 | 28.07K | 11 |      2215 | 19.61K | 35 |   10.0 |  3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q0L0X80P000    |   80.0 |  57.12% |      4313 | 39.25K | 10 |      2506 | 15.13K | 34 |   20.0 |  5.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q0L0X80P001    |   80.0 |  55.77% |      3849 | 40.89K | 12 |      2506 | 16.15K | 40 |   17.0 |  5.0 |   3.0 |  34.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q0L0X80P002    |   80.0 |  56.36% |      4616 | 39.65K | 12 |      2506 | 16.33K | 40 |   20.0 | 10.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q0L0X120P000   |  120.0 |  56.92% |      4516 | 45.78K | 13 |      6255 | 12.07K | 39 |   29.0 | 12.0 |   3.0 |  58.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q0L0X120P001   |  120.0 |  56.03% |      4716 |    44K | 11 |      6254 | 11.75K | 33 |   30.0 | 14.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'25'' |
| Q0L0X160P000   |  160.0 |  55.57% |      4528 | 44.68K | 13 |      6255 | 11.79K | 31 |   39.0 | 14.0 |   3.0 |  78.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q0L0X240P000   |  240.0 |  56.39% |      4724 | 44.02K | 13 |      6254 | 11.69K | 33 |   59.0 | 19.5 |   3.0 | 118.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'25'' |
| Q20L60X40P000  |   40.0 |  54.19% |      2475 | 31.48K | 11 |      6255 | 12.01K | 27 |   12.0 |  4.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q20L60X40P001  |   40.0 |  53.89% |      2520 |  30.1K | 12 |      2506 | 13.86K | 32 |   11.0 |  3.5 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q20L60X40P002  |   40.0 |  54.15% |      1998 | 36.49K | 17 |      6255 | 12.23K | 37 |   13.0 |  4.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'25'' |
| Q20L60X80P000  |   80.0 |  55.42% |      7454 | 40.51K | 11 |      6255 | 11.97K | 29 |   19.0 |  8.5 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q20L60X80P001  |   80.0 |  57.07% |      4556 | 40.49K | 11 |      2506 | 15.52K | 40 |   20.0 |  6.5 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'25'' |
| Q20L60X80P002  |   80.0 |  56.66% |      4475 |  41.3K | 11 |      6254 | 11.93K | 33 |   22.0 |  8.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q20L60X120P000 |  120.0 |  56.24% |      4591 | 41.42K | 11 |      2506 | 16.54K | 36 |   26.0 | 10.0 |   3.0 |  52.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q20L60X120P001 |  120.0 |  55.68% |      3768 | 42.28K | 12 |      2506 |  12.8K | 30 |   32.0 |  8.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'27'' |
| Q20L60X160P000 |  160.0 |  56.78% |      4633 | 43.09K | 12 |      6255 | 12.44K | 37 |   36.0 | 11.0 |   3.0 |  72.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'27'' |
| Q20L60X240P000 |  240.0 |  56.34% |      4573 | 41.85K | 11 |      2506 | 13.72K | 30 |   58.0 | 11.0 |   8.3 | 116.0 | "31,41,51,61,71,81" | 0:00'18'' | 0:00'27'' |
| Q25L60X40P000  |   40.0 |  53.75% |      2467 | 27.93K | 11 |      2506 | 12.82K | 30 |   13.0 |  4.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q25L60X40P001  |   40.0 |  67.34% |      2180 | 36.63K | 16 |      6254 | 19.81K | 41 |   13.0 |  5.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q25L60X40P002  |   40.0 |  55.05% |      3119 |  32.1K | 14 |      6254 | 12.49K | 35 |   11.0 |  3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q25L60X80P000  |   80.0 |  58.59% |      4680 | 43.37K | 12 |      2506 | 16.17K | 49 |   20.0 |  8.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| Q25L60X80P001  |   80.0 |  55.52% |      3986 | 39.79K | 11 |      2506 | 13.31K | 28 |   20.0 |  5.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q25L60X80P002  |   80.0 |  55.38% |      4498 | 38.21K | 10 |      2506 | 15.62K | 33 |   19.0 |  9.0 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q25L60X120P000 |  120.0 |  58.52% |      3807 | 52.12K | 16 |      6254 | 12.12K | 47 |   30.0 | 10.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'27'' |
| Q25L60X120P001 |  120.0 |  55.69% |      4529 | 42.75K | 12 |      2506 | 12.75K | 33 |   28.0 | 12.5 |   3.0 |  56.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'27'' |
| Q25L60X160P000 |  160.0 |  56.76% |      4672 |    42K | 11 |      2506 | 13.78K | 30 |   39.0 |  8.0 |   5.0 |  78.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| Q25L60X240P000 |  240.0 |  56.88% |      4623 | 42.29K | 11 |      2506 | 14.47K | 33 |   60.0 | 13.0 |   7.0 | 120.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| Q30L60X40P000  |   40.0 |  55.97% |      2969 | 30.86K | 13 |      2506 | 14.34K | 39 |   13.0 |  3.5 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q30L60X40P001  |   40.0 |  55.61% |      2104 | 33.03K | 15 |      2506 | 13.45K | 38 |   12.0 |  3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'25'' |
| Q30L60X40P002  |   40.0 |  54.80% |      2840 | 32.81K | 13 |      6254 | 12.33K | 33 |   13.0 |  4.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q30L60X80P000  |   80.0 |  58.47% |      3528 | 41.63K | 13 |      2506 | 15.28K | 49 |   20.0 |  9.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'25'' |
| Q30L60X80P001  |   80.0 |  58.46% |      3395 | 48.06K | 16 |      2506 | 13.25K | 46 |   22.0 |  6.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'26'' |
| Q30L60X80P002  |   80.0 |  56.76% |      2958 |  42.2K | 16 |      2215 | 18.08K | 43 |   19.0 |  8.5 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q30L60X120P000 |  120.0 |  57.79% |      4755 | 46.61K | 12 |      2506 | 12.88K | 36 |   33.0 | 11.0 |   3.0 |  66.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| Q30L60X120P001 |  120.0 |  57.40% |      4526 | 41.86K | 12 |      2506 | 17.47K | 38 |   29.0 | 13.5 |   3.0 |  58.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| Q30L60X160P000 |  160.0 |  56.56% |      4768 | 43.97K | 11 |      6255 | 11.58K | 27 |   43.0 | 15.0 |   3.0 |  86.0 | "31,41,51,61,71,81" | 0:00'18'' | 0:00'26'' |
| Q30L60X240P000 |  240.0 |  57.08% |      4584 | 42.07K | 11 |      2506 | 13.63K | 32 |   62.0 | 13.5 |   7.2 | 124.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'27'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |    Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|-------:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  67.84% |      2512 | 32.79K | 14 |      2038 | 40.25K | 61 |   11.0 | 5.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| MRX40P001 |   40.0 |  66.80% |      2509 | 36.98K | 16 |      1184 | 38.02K | 85 |   10.0 | 3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'27'' |
| MRX40P002 |   40.0 |  61.43% |      2180 | 32.75K | 14 |      1708 | 34.56K | 66 |   11.0 | 4.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'26'' |
| MRX80P000 |   80.0 |  14.86% |      1929 |  3.34K |  2 |      1044 |  8.64K | 11 |   15.0 | 6.0 |   3.0 |  30.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'25'' |
| MRX80P001 |   80.0 |   5.92% |      1097 |   1.1K |  1 |      1212 |  2.33K |  4 |   14.0 | 6.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:00'08'' | 0:00'24'' |
| MRX80P002 |   80.0 |   7.31% |      1112 |  3.34K |  3 |      1080 |  6.22K | 11 |   16.0 | 7.0 |   3.0 |  32.0 | "31,41,51,61,71,81" | 0:00'08'' | 0:00'25'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |  # | N50Others |    Sum |  # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|---:|----------:|-------:|---:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  53.97% |      2512 | 33.37K | 14 |      2506 | 14.74K | 39 |   12.0 |  4.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'26'' |
| MRX40P001  |   40.0 |  54.30% |      4350 | 36.92K | 12 |      2215 | 18.62K | 37 |   11.0 |  3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| MRX40P002  |   40.0 |  59.12% |      2747 | 32.02K | 11 |      2506 | 17.91K | 32 |   12.0 |  3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'25'' |
| MRX80P000  |   80.0 |  54.39% |      8281 | 41.58K | 10 |      2506 | 15.19K | 29 |   21.0 |  5.5 |   3.0 |  42.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| MRX80P001  |   80.0 |  55.38% |      4584 | 51.11K | 15 |      2506 | 16.41K | 42 |   20.0 |  4.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'25'' |
| MRX80P002  |   80.0 |  59.25% |      3706 | 49.82K | 16 |      2506 | 14.39K | 37 |   21.0 |  5.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| MRX120P000 |  120.0 |  54.83% |      4562 |  44.7K | 13 |      2215 | 17.96K | 36 |   30.0 | 10.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| MRX120P001 |  120.0 |  54.25% |      4595 | 43.84K | 12 |      2506 | 15.72K | 37 |   30.0 |  6.0 |   4.0 |  60.0 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'26'' |
| MRX160P000 |  160.0 |  54.47% |      3559 | 47.56K | 14 |      2506 | 12.83K | 35 |   42.0 | 11.5 |   3.0 |  84.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| MRX160P001 |  160.0 |  54.56% |      4677 | 45.18K | 13 |      2506 | 14.96K | 39 |   40.0 | 11.5 |   3.0 |  80.0 | "31,41,51,61,71,81" | 0:00'17'' | 0:00'26'' |
| MRX240P000 |  240.0 |  52.83% |      4732 | 44.82K | 13 |      6255 | 11.38K | 26 |   59.0 | 26.0 |   3.0 | 118.0 | "31,41,51,61,71,81" | 0:00'18'' | 0:00'27'' |
| MRX320P000 |  320.0 |  53.06% |      4740 | 45.13K | 13 |      6255 | 11.19K | 26 |   79.0 | 37.5 |   3.0 | 158.0 | "31,41,51,61,71,81" | 0:00'18'' | 0:00'27'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |  # | N50Others |     Sum |  # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|---:|----------:|--------:|---:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  14.42% |      3563 | 36.15K | 14 |      2064 | 138.12K | 77 |   22.0 | 10.0 |   3.0 |  44.0 | 0:00'29'' |
| 7_mergeKunitigsAnchors   |  17.22% |      3599 | 40.77K | 16 |      1558 |   72.4K | 48 |   24.0 |  8.5 |   3.0 |  48.0 | 0:00'28'' |
| 7_mergeMRKunitigsAnchors |  24.08% |      8296 | 42.47K | 12 |      2009 |  78.59K | 44 |   31.0 |  9.0 |   3.0 |  62.0 | 0:00'29'' |
| 7_mergeMRTadpoleAnchors  |  18.58% |      3530 | 30.34K | 11 |      2291 |  61.28K | 32 |   23.0 | 10.5 |   3.0 |  46.0 | 0:00'27'' |
| 7_mergeTadpoleAnchors    |  20.85% |      3599 | 36.55K | 15 |      2506 |  66.82K | 35 |   24.0 |  9.0 |   3.0 |  48.0 | 0:00'29'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |  # | N50Others |    Sum |  # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|---:|----------:|-------:|---:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  65.48% |      2137 |    34K | 16 |      2688 | 83.33K | 53 |   18.0 | 14.0 |   3.0 |  36.0 | 0:00'30'' |
| 8_spades_MR  |  67.73% |      2950 | 48.85K | 20 |      2346 | 54.07K | 56 |   23.0 | 16.5 |   3.0 |  46.0 | 0:00'28'' |
| 8_megahit    |  58.66% |      3050 | 36.22K | 15 |      2095 | 49.61K | 43 |   23.0 | 12.5 |   3.0 |  46.0 | 0:00'30'' |
| 8_megahit_MR |  65.39% |      3145 | 40.32K | 18 |      2361 | 47.53K | 52 |   23.0 | 15.5 |   3.0 |  46.0 | 0:00'28'' |
| 8_platanus   |  55.39% |      2741 | 38.06K | 14 |      2902 | 16.57K | 30 |   43.0 | 12.0 |   3.0 |  86.0 | 0:00'28'' |


Table: statFinal

| Name                     |   N50 |    Sum |    # |
|:-------------------------|------:|-------:|-----:|
| Genome                   | 85779 |  85779 |    1 |
| 7_mergeAnchors.anchors   |  3563 |  36147 |   14 |
| 7_mergeAnchors.others    |  2064 | 138118 |   77 |
| anchorLong               |  3563 |  34929 |   12 |
| anchorFill               |  7404 |  38582 |    9 |
| spades.contig            |   531 | 297581 | 1009 |
| spades.scaffold          |   545 | 297621 | 1005 |
| spades.non-contained     |  3821 | 117326 |   37 |
| spades_MR.contig         |  1031 | 204302 |  460 |
| spades_MR.scaffold       |  1031 | 204302 |  460 |
| spades_MR.non-contained  |  3566 | 102917 |   36 |
| megahit.contig           |   630 | 220393 |  406 |
| megahit.non-contained    |  3966 |  85830 |   28 |
| megahit_MR.contig        |   551 | 302073 |  533 |
| megahit_MR.non-contained |  3304 |  87852 |   34 |
| platanus.contig          |   885 | 101894 |  257 |
| platanus.scaffold        |  2429 |  86966 |  223 |
| platanus.non-contained   |  4407 |  54630 |   16 |


# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## s288cMito: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/s288cMito
cd ${HOME}/data/anchr/s288cMito

mkdir -p 1_genome
cd 1_genome

faops order ~/data/anchr/s288c/1_genome/genome.fa \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI}; do echo $chr; done) \
    ref.fa

faops order ~/data/anchr/s288c/1_genome/genome.fa \
    <(echo Mito) \
    genome.fa

```

* Illumina

```bash
mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina
cd ${HOME}/data/anchr/s288cMito/2_illumina

ln -sf ${HOME}/data/anchr/s288c/2_illumina/R1.fq.gz R1.fq.gz
ln -sf ${HOME}/data/anchr/s288c/2_illumina/R2.fq.gz R2.fq.gz

mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/trim
cd ${HOME}/data/anchr/s288cMito/2_illumina/trim

ln -sf ${HOME}/data/anchr/s288c/2_illumina/trim/R1.fq.gz R1.fq.gz
ln -sf ${HOME}/data/anchr/s288c/2_illumina/trim/R2.fq.gz R2.fq.gz

```

## s288cMito: ref

```bash
mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/ref
cd ${HOME}/data/anchr/s288cMito/2_illumina/ref

anchr trim \
    --dedupe \
    --qual 20 --len 60 \
    --filter "adapter,phix,artifact" \
    --artifact ../../1_genome/ref.fa \
    --matchk 31 \
    --parallel 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o trim.sh
bash trim.sh

tadwrapper.sh \
    in=filter.fq.gz \
    out=contigs_%.fa \
    k=31,41,51,61,71,81 bisect \
    outfinal=contigs.fa

# Alignment; only use merged reads
bbmap.sh \
    in=filter.fq.gz \
    outm=mapped.sam.gz outu=unmapped.sam.gz \
    ref=../../1_genome/genome.fa \
    nodisk slow bs=bs.sh overwrite

callvariants.sh \
    in=mapped.sam.gz out=vars.txt \
    vcf=vars.vcf.gz ref=../../1_genome/genome.fa \
    ploidy=1 overwrite

# Generate a bam file, if viewing in IGV is desired.
bash bs.sh

mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/mergereads
cd ${HOME}/data/anchr/s288cMito/2_illumina/mergereads

anchr mergereads \
    --ecphase "1,3" \
    --parallel 16 \
    ../trim/filter.fq.gz \
    -o mergereads.sh
bash mergereads.sh

tadwrapper.sh \
    in=pe.cor.fa.gz \
    out=contigs_%.fa \
    k=25,55,95,125 bisect \
    outfinal=contigs.fa

```

## s288cMito: filter

```bash
mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/filter
cd ${HOME}/data/anchr/s288cMito/2_illumina/filter

clumpify.sh \
    in=../trim/R1.fq.gz \
    in2=../trim/R2.fq.gz \
    out=reads.fq.gz \
    dedupe dupesubs=0

kmercountexact.sh \
    in=reads.fq.gz \
    khist=khist_raw.txt peaks=peaks_raw.txt

primary=`grep "haploid_fold_coverage" peaks_raw.txt | sed "s/^.*\t//g"`
cutoff=$(( $primary * 3 ))

bbnorm.sh in=reads.fq.gz out=highpass.fq.gz pigz passes=1 bits=16 min=$cutoff target=9999999
#reformat.sh in=highpass.fq.gz out=highpass_gc.fq.gz maxgc=0.45

#fastqc highpass.fq.gz highpass_gc.fq.gz

kmercountexact.sh \
    in=highpass.fq.gz \
    khist=khist_100.txt k=100 \
    peaks=peaks_100.txt \
    smooth ow smoothradius=1 maxradius=1000 progressivemult=1.06 maxpeaks=16 prefilter=2

mitopeak=`grep "main_peak" peaks_100.txt | sed "s/^.*\t//g"`

upper=$((mitopeak * 6 / 3))
lower=$((mitopeak * 3 / 7))
mcs=$((mitopeak * 3 / 4))
mincov=$((mitopeak * 2 / 3))

tadwrapper.sh \
    in=highpass_gc.fq.gz \
    out=contigs_intermediate_%.fa \
    k=78,100,120 \
    outfinal=contigs_intermediate.fa prefilter=2 mincr=$lower maxcr=$upper mcs=$mcs mincov=$mincov

bbduk.sh \
    in=highpass.fq.gz \
    ref=contigs_intermediate.fa \
    outm=bbd005.fq.gz k=31 mm=f mkf=0.05

tadpole.sh \
    in=bbd005.fq.gz \
    out=contigs_bbd.fa \
    prefilter=2 mincr=$((mitopeak * 3 / 8)) maxcr=$((upper * 2)) mcs=$mcs mincov=$mincov k=100 bm1=6

```

```bash
cd ${HOME}/data/anchr/s288cMito

rm -fr 9_quast_mito
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    ${HOME}/data/anchr/s288cMito/2_illumina/trim/contigs.fa \
    ${HOME}/data/anchr/s288cMito/2_illumina/mergereads/contigs.fa \
    ${HOME}/data/anchr/s288cMito/2_illumina/filter/contigs_bbd.fa \
    --label "trim,mergereads,filter" \
    -o 9_quast_mito



```
