FROM legionio/legion

COPY . /usr/src/app/lex-rfp

WORKDIR /usr/src/app/lex-rfp
RUN bundle install
