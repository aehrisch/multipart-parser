# Contains fixturues to
module MultipartParser::Fixtures
  # Returns all fixtures in the module
  def fixtures
    [Rfc1867.new, NoTrailingCRLF.new, EmptyHeader.new, BoundaryWithCRLF.new]
  end
  extend self

  class Rfc1867
    def boundary
      'AaB03x'
    end

    def expect_error
      false
    end

    def parts
      part1, part2 = {}, {}
      part1[:headers] = {'content-disposition' => 'form-data; name="field1"'}
      part1[:data] = "Joe Blow\r\nalmost tricked you!"
      part2[:headers] = {}
      part2[:headers]['content-disposition'] = 'form-data; name="pics"; ' +
                                                'filename="file1.txt"'
      part2[:headers]['Content-Type'] = 'text/plain'
      part2[:data] = "... contents of file1.txt ...\r"
      [part1, part2]
    end

    def raw
      ['--AaB03x',
        'content-disposition: form-data; name="field1"',
        '',
        "Joe Blow\r\nalmost tricked you!",
        '--AaB03x',
        'content-disposition: form-data; name="pics"; filename="file1.txt"',
        'Content-Type: text/plain',
        '',
        "... contents of file1.txt ...\r",
        '--AaB03x--',
        ''
      ].join("\r\n")
    end
  end

  class NoTrailingCRLF
    def boundary
      'AaB03x'
    end

    def expect_error
      false
    end

    def parts
      part1, part2 = {}, {}
      part1[:headers] = {'content-disposition' => 'form-data; name="field1"'}
      part1[:data] = "Joe Blow\r\nalmost tricked you!"
      part2[:headers] = {}
      part2[:headers]['content-disposition'] = 'form-data; name="pics"; ' +
                                                'filename="file1.txt"'
      part2[:headers]['Content-Type'] = 'text/plain'
      part2[:data] = "... contents of file1.txt ...\r"
      [part1, part2]
    end

    def raw
      ['--AaB03x',
        'content-disposition: form-data; name="field1"',
        '',
        "Joe Blow\r\nalmost tricked you!",
        '--AaB03x',
        'content-disposition: form-data; name="pics"; filename="file1.txt"',
        'Content-Type: text/plain',
        '',
        "... contents of file1.txt ...\r",
        '--AaB03x--'
      ].join("\r\n")
    end
  end

  class BoundaryWithCRLF
    def boundary
      'uuid:608af275-e2c6-4302-93df-687a25ccd1c3'
    end

    def expect_error
      false
    end

    def parts
      part1, part2 = {}, {}
      part1[:headers] = {
        'Content-Id' => '<rootpart>',
        'Content-Type' => 'application/xop+xml;charset=utf-8;type="application/soap+xml"',
        'Content-Transfer-Encoding' => 'binary' }
      part1[:data] = "<somexml>foobar</somexml>\r\n"

      part2[:headers] = {
        'Content-Id' => '<4b7a6950-9006-4634-b041-a11dfa98ba89>',
        'Content-Type' => 'null',
        'Content-Transfer-Encoding' => 'binary'
      }
      part2[:data] = "1\r\n2\r\n3"
      [part1, part2]
    end

    def raw
      ['--uuid:608af275-e2c6-4302-93df-687a25ccd1c3',
       'Content-Id: <rootpart>',
       'Content-Type: application/xop+xml;charset=utf-8;type="application/soap+xml"',
       'Content-Transfer-Encoding: binary',
       '',
       '<somexml>foobar</somexml>',
       "\r\n",
       '--uuid:608af275-e2c6-4302-93df-687a25ccd1c3',
       'Content-Id: <4b7a6950-9006-4634-b041-a11dfa98ba89>',
       'Content-Type: null',
       'Content-Transfer-Encoding: binary',
       '',
       '1',
       '2',
       '3',
       '',
       '--uuid:608af275-e2c6-4302-93df-687a25ccd1c3--'].join("\r\n")
    end
  end

  class LongBoundary
    def boundary
      '----------------------------5c4dc587f69f'
    end

    def expect_error
      false
    end

    def parts
      part1 = {}
      part1[:headers] = {'content-disposition' => 'form-data; name="field1"'}
      part1[:data] = "Joe Blow\r\nalmost tricked you!"
      [part1]
    end

    def raw
      ['----------------------------5c4dc587f69f',
        'content-disposition: form-data; name="field1"',
        '',
        "Joe Blow\r\nalmost tricked you!",
        '----------------------------5c4dc587f69f--'
      ].join("\r\n")
    end
  end

  class EmptyHeader
    def boundary
      'AaB03x'
    end

    def expect_error
      true
    end

    def parts
      [] # Should never be called
    end

    def raw
      ['--AaB03x',
        'content-disposition: form-data; name="field1"',
        ': foo',
        '',
        "Joe Blow\r\nalmost tricked you!",
        '--AaB03x',
        'content-disposition: form-data; name="pics"; filename="file1.txt"',
        'Content-Type: text/plain',
        '',
        "... contents of file1.txt ...\r",
        '--AaB03x--',
        ''
      ].join("\r\n")
    end
  end
end
