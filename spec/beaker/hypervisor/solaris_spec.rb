require 'spec_helper'

module Beaker
  describe Aixer do
    let( :solaris) { Beaker::Solaris.new( @hosts, make_opts ) }

    before :each do
      @hosts = make_hosts()
      File.stub( :exists? ).and_return( true )
      YAML.stub( :load_file ).and_return( fog_file_contents )
      Host.any_instance.stub( :exec ).and_return( true )
    end

    it "can provision a set of hosts" do
      vmpath = "rpoooool/zs"
      spath = "rpoooool/USER/z0"

      @hosts.each do |host|
        vm_name = host['vmname'] || host.name
        snapshot = host['snapshot']
        Command.should_receive( :new ).with("sudo /sbin/zfs rollback -Rf #{vmpath}/#{vm_name}@#{snapshot}").exactly( 1 ).times
        Command.should_receive( :new ).with("sudo /sbin/zfs rollback -Rf #{vmpath}/#{vm_name}/#{spath}@#{snapshot}").exactly( 1 ).times
        Command.should_receive( :new ).with("sudo /sbin/zoneadm -z #{vm_name} boot").exactly( 1 ).times
      end

      solaris.provision
    end

    it "does nothing for cleanup" do
      Command.should_receive( :new ).exactly( 0 ).times
      Host.should_receive( :exec ).exactly( 0 ).times

      solaris.cleanup
    end


  end

end
